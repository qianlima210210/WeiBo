//
//  BYStatDatabaseQueue.m
//  BYStatdb
//
//  Created by August Mueller on 6/22/11.
//  Copyright 2011 Flying Meat Inc. All rights reserved.
//

#import "BYStatDatabaseQueue.h"
#import "BYStatDatabase.h"

#if BYStatDB_SQLITE_STANDALONE
#import <sqlite3/sqlite3.h>
#else
#import <sqlite3.h>
#endif

typedef NS_ENUM(NSInteger, BYStatDBTransaction) {
    BYStatDBTransactionExclusive,
    BYStatDBTransactionDeferred,
    BYStatDBTransactionImmediate,
};

/*
 
 Note: we call [self retain]; before using dispatch_sync, just incase 
 BYStatDatabaseQueue is released on another thread and we're in the middle of doing
 something in dispatch_sync
 
 */

/*
 * A key used to associate the BYStatDatabaseQueue object with the dispatch_queue_t it uses.
 * This in turn is used for deadlock detection by seeing if inDatabase: is called on
 * the queue's dispatch queue, which should not happen and causes a deadlock.
 */
static const void * const kDispatchQueueSpecificKey = &kDispatchQueueSpecificKey;

@interface BYStatDatabaseQueue () {
    dispatch_queue_t    _queue;
    BYStatDatabase          *_db;
}
@end

@implementation BYStatDatabaseQueue

+ (instancetype)databaseQueueWithPath:(NSString *)aPath {
    BYStatDatabaseQueue *q = [[self alloc] initWithPath:aPath];
    
    BYStatDBAutorelease(q);
    
    return q;
}

+ (instancetype)databaseQueueWithURL:(NSURL *)url {
    return [self databaseQueueWithPath:url.path];
}

+ (instancetype)databaseQueueWithPath:(NSString *)aPath flags:(int)openFlags {
    BYStatDatabaseQueue *q = [[self alloc] initWithPath:aPath flags:openFlags];
    
    BYStatDBAutorelease(q);
    
    return q;
}

+ (instancetype)databaseQueueWithURL:(NSURL *)url flags:(int)openFlags {
    return [self databaseQueueWithPath:url.path flags:openFlags];
}

+ (Class)databaseClass {
    return [BYStatDatabase class];
}

- (instancetype)initWithURL:(NSURL *)url flags:(int)openFlags vfs:(NSString *)vfsName {
    return [self initWithPath:url.path flags:openFlags vfs:vfsName];
}

- (instancetype)initWithPath:(NSString*)aPath flags:(int)openFlags vfs:(NSString *)vfsName {
    self = [super init];
    
    if (self != nil) {
        
        _db = [[[self class] databaseClass] databaseWithPath:aPath];
        BYStatDBRetain(_db);
        
#if SQLITE_VERSION_NUMBER >= 3005000
        BOOL success = [_db openWithFlags:openFlags vfs:vfsName];
#else
        BOOL success = [_db open];
#endif
        if (!success) {
            NSLog(@"Could not create database queue for path %@", aPath);
            BYStatDBRelease(self);
            return 0x00;
        }
        
        _path = BYStatDBReturnRetained(aPath);
        
        _queue = dispatch_queue_create([[NSString stringWithFormat:@"BYStatdb.%@", self] UTF8String], NULL);
        dispatch_queue_set_specific(_queue, kDispatchQueueSpecificKey, (__bridge void *)self, NULL);
        _openFlags = openFlags;
        _vfsName = [vfsName copy];
    }
    
    return self;
}

- (instancetype)initWithPath:(NSString *)aPath flags:(int)openFlags {
    return [self initWithPath:aPath flags:openFlags vfs:nil];
}

- (instancetype)initWithURL:(NSURL *)url flags:(int)openFlags {
    return [self initWithPath:url.path flags:openFlags vfs:nil];
}

- (instancetype)initWithURL:(NSURL *)url {
    return [self initWithPath:url.path];
}

- (instancetype)initWithPath:(NSString *)aPath {
    // default flags for sqlite3_open
    return [self initWithPath:aPath flags:SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE vfs:nil];
}

- (instancetype)init {
    return [self initWithPath:nil];
}

- (void)dealloc {
    BYStatDBRelease(_db);
    BYStatDBRelease(_path);
    BYStatDBRelease(_vfsName);
    
    if (_queue) {
        BYStatDBDispatchQueueRelease(_queue);
        _queue = 0x00;
    }
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

- (void)close {
    BYStatDBRetain(self);
    dispatch_sync(_queue, ^() {
        [self->_db close];
        BYStatDBRelease(_db);
        self->_db = 0x00;
    });
    BYStatDBRelease(self);
}

- (void)interrupt {
    [[self database] interrupt];
}

- (BYStatDatabase*)database {
    if (!_db) {
       _db = BYStatDBReturnRetained([[[self class] databaseClass] databaseWithPath:_path]);
        
#if SQLITE_VERSION_NUMBER >= 3005000
        BOOL success = [_db openWithFlags:_openFlags vfs:_vfsName];
#else
        BOOL success = [_db open];
#endif
        if (!success) {
            NSLog(@"BYStatDatabaseQueue could not reopen database for path %@", _path);
            BYStatDBRelease(_db);
            _db  = 0x00;
            return 0x00;
        }
    }
    
    return _db;
}

- (void)inDatabase:(void (^)(BYStatDatabase *db))block {
#ifndef NDEBUG
    /* Get the currently executing queue (which should probably be nil, but in theory could be another DB queue
     * and then check it against self to make sure we're not about to deadlock. */
    BYStatDatabaseQueue *currentSyncQueue = (__bridge id)dispatch_get_specific(kDispatchQueueSpecificKey);
    assert(currentSyncQueue != self && "inDatabase: was called reentrantly on the same queue, which would lead to a deadlock");
#endif
    
    BYStatDBRetain(self);
    
    dispatch_sync(_queue, ^() {
        
        BYStatDatabase *db = [self database];
        
        block(db);
        
        if ([db hasOpenResultSets]) {
            NSLog(@"Warning: there is at least one open result set around after performing [BYStatDatabaseQueue inDatabase:]");
            
#if defined(DEBUG) && DEBUG
            NSSet *openSetCopy = BYStatDBReturnAutoreleased([[db valueForKey:@"_openResultSets"] copy]);
            for (NSValue *rsInWrappedInATastyValueMeal in openSetCopy) {
                BYStatResultSet *rs = (BYStatResultSet *)[rsInWrappedInATastyValueMeal pointerValue];
                NSLog(@"query: '%@'", [rs query]);
            }
#endif
        }
    });
    
    BYStatDBRelease(self);
}

- (void)beginTransaction:(BYStatDBTransaction)transaction withBlock:(void (^)(BYStatDatabase *db, BOOL *rollback))block {
    BYStatDBRetain(self);
    dispatch_sync(_queue, ^() { 
        
        BOOL shouldRollback = NO;

        switch (transaction) {
            case BYStatDBTransactionExclusive:
                [[self database] beginTransaction];
                break;
            case BYStatDBTransactionDeferred:
                [[self database] beginDeferredTransaction];
                break;
            case BYStatDBTransactionImmediate:
                [[self database] beginImmediateTransaction];
                break;
        }
        
        block([self database], &shouldRollback);
        
        if (shouldRollback) {
            [[self database] rollback];
        }
        else {
            [[self database] commit];
        }
    });
    
    BYStatDBRelease(self);
}

- (void)inTransaction:(void (^)(BYStatDatabase *db, BOOL *rollback))block {
    [self beginTransaction:BYStatDBTransactionExclusive withBlock:block];
}

- (void)inDeferredTransaction:(void (^)(BYStatDatabase *db, BOOL *rollback))block {
    [self beginTransaction:BYStatDBTransactionDeferred withBlock:block];
}

- (void)inExclusiveTransaction:(void (^)(BYStatDatabase *db, BOOL *rollback))block {
    [self beginTransaction:BYStatDBTransactionExclusive withBlock:block];
}

- (void)inImmediateTransaction:(void (^)(BYStatDatabase * _Nonnull, BOOL * _Nonnull))block {
    [self beginTransaction:BYStatDBTransactionImmediate withBlock:block];
}

- (NSError*)inSavePoint:(void (^)(BYStatDatabase *db, BOOL *rollback))block {
#if SQLITE_VERSION_NUMBER >= 3007000
    static unsigned long savePointIdx = 0;
    __block NSError *err = 0x00;
    BYStatDBRetain(self);
    dispatch_sync(_queue, ^() { 
        
        NSString *name = [NSString stringWithFormat:@"savePoint%ld", savePointIdx++];
        
        BOOL shouldRollback = NO;
        
        if ([[self database] startSavePointWithName:name error:&err]) {
            
            block([self database], &shouldRollback);
            
            if (shouldRollback) {
                // We need to rollback and release this savepoint to remove it
                [[self database] rollbackToSavePointWithName:name error:&err];
            }
            [[self database] releaseSavePointWithName:name error:&err];
            
        }
    });
    BYStatDBRelease(self);
    return err;
#else
    NSString *errorMessage = NSLocalizedString(@"Save point functions require SQLite 3.7", nil);
    if (self.logsErrors) NSLog(@"%@", errorMessage);
    return [NSError errorWithDomain:@"BYStatDatabase" code:0 userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
#endif
}

- (BOOL)checkpoint:(BYStatDBCheckpointMode)mode error:(NSError * __autoreleasing *)error
{
    return [self checkpoint:mode name:nil logFrameCount:NULL checkpointCount:NULL error:error];
}

- (BOOL)checkpoint:(BYStatDBCheckpointMode)mode name:(NSString *)name error:(NSError * __autoreleasing *)error
{
    return [self checkpoint:mode name:name logFrameCount:NULL checkpointCount:NULL error:error];
}

- (BOOL)checkpoint:(BYStatDBCheckpointMode)mode name:(NSString *)name logFrameCount:(int * _Nullable)logFrameCount checkpointCount:(int * _Nullable)checkpointCount error:(NSError * __autoreleasing _Nullable * _Nullable)error
{
    __block BOOL result;
    __block NSError *blockError;
    
    BYStatDBRetain(self);
    dispatch_sync(_queue, ^() {
        result = [self.database checkpoint:mode name:name logFrameCount:NULL checkpointCount:NULL error:&blockError];
    });
    BYStatDBRelease(self);
    
    if (error) {
        *error = blockError;
    }
    return result;
}

@end
