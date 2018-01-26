//
//  BYStatSqliteHandleCoordinator.m
//  BYStat
//
//  Created by QDHL on 2017/11/28.
//  Copyright © 2017年 QDHL. All rights reserved.
//

#import "BYStatSqliteHandleCoordinator.h"
#import "BYStatDB.h"
#import "BYStatCommonDefine.h"
#import "BYStatUploadDataMerger.h"
#import "BYStatThreadForSqliteHandle.h"

@interface BYStatSqliteHandleCoordinator ()

//MARK: -- 数据库队列及数据库路径信息
@property NSUInteger dbVersion;                                                 //数据库版本号,从1开始记录
@property BOOL allowDBanipulate;                                                //是否允许数据库操作，默认为YES，即允许
@property (nonatomic, strong)   BYStatDatabaseQueue *dbQueue;                   //数据库操作队列
@property (nonatomic, copy)     NSString *dbPath;                               //数据库文件全路径, eg:/Documents/xxx.sqlite

//MARK: -- BaseInfoTable表名及相关字段信息
@property (nonatomic, copy)     NSString *tableNameOfBaseInfoTable;             //基本信息表名
@property (nonatomic, strong)   NSArray *fieldNamesOfBaseInfoTable;             //基本信息表中包含的字段名数组
@property (nonatomic, strong)   NSArray *fieldTypesOfBaseInfoTable;             //基本信息表中包含的字段类型数组

//MARK: -- ApplicationInfoTable表名及相关字段信息
@property (nonatomic, copy)     NSString *tableNameOfApplicationInfoTable;      //应用信息表名
@property (nonatomic, strong)   NSArray *fieldNamesOfApplicationInfoTable;      //应用信息表中包含的字段名数组
@property (nonatomic, strong)   NSArray *fieldTypesOfApplicationInfoTable;      //应用信息表中包含的字段类型数组

//MARK: -- AccountInfoTable表名及相关字段信息
@property (nonatomic, copy)     NSString *tableNameOfAccountInfoTable;          //账户信息表名
@property (nonatomic, strong)   NSArray *fieldNamesOfAccountInfoTable;          //账户信息表中包含的字段名数组
@property (nonatomic, strong)   NSArray *fieldTypesOfAccountInfoTable;          //账户信息表中包含的字段类型数组

//MARK: -- PageInfoTable表名及相关字段信息
@property (nonatomic, copy)     NSString *tableNameOfPageInfoTable;             //页面信息表名
@property (nonatomic, strong)   NSArray *fieldNamesOfPageInfoTable;             //页面信息表中包含的字段名数组
@property (nonatomic, strong)   NSArray *fieldTypesOfPageInfoTable;             //页面信息表中包含的字段类型数组

//MARK: -- EventInfoTable表名及相关字段信息
@property (nonatomic, copy)     NSString *tableNameOfEventInfoTable;            //事件信息表名
@property (nonatomic, strong)   NSArray *fieldNamesOfEventInfoTable;            //事件信息表中包含的字段名数组
@property (nonatomic, strong)   NSArray *fieldTypesOfEventInfoTable;            //事件信息表中包含的字段类型数组

//MARK: -- PositionInfoTable表名及相关字段信息
@property (nonatomic, copy)     NSString *tableNameOfPositionInfoTable;         //位置信息表名
@property (nonatomic, strong)   NSArray *fieldNamesOfPositionInfoTable;         //位置信息表中包含的字段名数组
@property (nonatomic, strong)   NSArray *fieldTypesOfPositionInfoTable;         //位置信息表中包含的字段类型数组

//MARK: -- NetworkInfoTable表名及相关字段信息
@property (nonatomic, copy)     NSString *tableNameOfNetworkInfoTable;          //网络信息表名
@property (nonatomic, strong)   NSArray *fieldNamesOfNetworkInfoTable;          //网络信息表中包含的字段名数组
@property (nonatomic, strong)   NSArray *fieldTypesOfNetworkInfoTable;          //网络信息表中包含的字段类型数组

/**
 初始化数据库相关项：创建数据库队列，建表，以及后续的数据库升级
 */
-(void)initAboutDB;

@end


//操作协调层：数据库、表的创建；数据库的兼容
@implementation BYStatSqliteHandleCoordinator

/**
 @return SqliteHandleCoordinator操作协调器
 */
+(instancetype)sharedSqliteHandleCoordinator{
    static dispatch_once_t onceToken;
    static BYStatSqliteHandleCoordinator *sqliteHandleCoordinator;
    
    dispatch_once(&onceToken, ^{
        sqliteHandleCoordinator = [[BYStatSqliteHandleCoordinator alloc]init];
    });
    
    return sqliteHandleCoordinator;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        BYStatThreadForSqliteHandle *thread = [BYStatThreadForSqliteHandle sharedThreadForSqliteHandle];
        [self performSelector:@selector(initAboutDB) onThread:thread withObject:nil waitUntilDone:NO];
    }
    return self;
}

/**
 初始化数据库相关项：创建数据库队列，建表，以及后续的数据库升级
 */
-(void)initAboutDB{
    //配置当前数据库版本号
    _dbVersion = 1;
    
    //配置库文件存储路径
    _dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"qd.sqlite"];
    BYStatLog([@"dbPath: " stringByAppendingString:_dbPath]);
    
    //创建数据库队列
    _dbQueue = [BYStatDatabaseQueue databaseQueueWithPath:_dbPath];
    
    //未来数据库升级操作
    [self backwardCompatibility];
    
    //下面开始逐一建标
    [self createBaseInfoTable];
    [self createApplicationInfoTable];
    [self createAccountInfoTable];
    [self createPageInfoTable];
    [self createEventInfoTable];
    [self createPositionInfoTable];
    [self createNetworkInfoTable];
}


/**
 1、向后兼容两个版本，其余版本直接从本地删除库
 2、获取老表记录-->揉进新表-->删除老表
 */
-(void)backwardCompatibility{
    /*
    //尝试从本地获取数据库版本号
    NSString *obj = [[NSUserDefaults standardUserDefaults]objectForKey:@"BY_dbVersion"];
    NSUInteger savedVersion = 0;
    if (obj) {
        savedVersion = obj.integerValue;
    }
    
    //第一次运行
    if (savedVersion == 0) {
        [self saveDBVersion];
        return;
    }
    
    //非第一次运行
    NSUInteger offset = _dbVersion - savedVersion;
    if (offset == 0) {
        return;
    }
    
    //说明高1版本的第一次运行
    if (offset == 1) {
        //兼容...
        
        [self saveDBVersion];
        return;
    }
    
    //说明高2版本的第一次运行
    if (offset == 2) {
        //兼容...
        
        [self saveDBVersion];
        return;
    }
    
    //高>2版本的第一次运行
    //删除库中所有表
    NSString *sqlDropBaseInfoTable          = [NSString stringWithFormat:@"drop table %@", _tableNameOfBaseInfoTable];
    NSString *sqlDropApplicationInfoTable   = [NSString stringWithFormat:@"drop table %@", _tableNameOfApplicationInfoTable];
    NSString *sqlDropPageInfoTable          = [NSString stringWithFormat:@"drop table %@", _tableNameOfPageInfoTable];
    NSString *sqlDropEventInfoTable         = [NSString stringWithFormat:@"drop table %@", _tableNameOfEventInfoTable];;
    NSString *sqlDropPositionInfoTable      = [NSString stringWithFormat:@"drop table %@", _tableNameOfPositionInfoTable];
    NSString *sqlDropNetworkInfoTable       = [NSString stringWithFormat:@"drop table %@", _tableNameOfNetworkInfoTable];
    NSString *sqlDropAccountInfoTable       = [NSString stringWithFormat:@"drop table %@", _tableNameOfAccountInfoTable];
    
    NSString *statements = [NSString stringWithFormat:@"%@;%@;%@;%@;%@;%@;%@;", sqlDropBaseInfoTable, sqlDropApplicationInfoTable,
                                                            sqlDropPageInfoTable, sqlDropEventInfoTable, sqlDropPositionInfoTable,
                                                                                sqlDropNetworkInfoTable, sqlDropAccountInfoTable];
    
    [_dbQueue inTransaction:^(BYStatDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        
        if ([db executeStatements:statements]) {
            //删除成功
            [self saveDBVersion];
            BYStatLog(@"删除库中所有表 success");
            return;
        }else{
            *rollback = YES;
            
        }
        
    }];
    */
}

/**
 将数据库版本保存到本地
 */
-(void)saveDBVersion{
    NSString *obj = [NSString stringWithFormat:@"%lu", (unsigned long)_dbVersion];
    [[NSUserDefaults standardUserDefaults]setObject:obj forKey:@"BY_dbVersion"];
}

/**
 创建BaseInfoTable
 */
-(void)createBaseInfoTable{
    _tableNameOfBaseInfoTable = @"BaseInfo";
    _fieldNamesOfBaseInfoTable = @[kBYSTIDKey,
                                   kBYSTApplicationChannelKey,
                                   kBYSTApplicationKeyKey,
                                   kBYSTApplicationNameKey,
                                   kBYSTApplicationPackageNameKey,
                                   kBYSTApplicationVersionKey,
                                   kBYSTDeviceBrandKey,
                                   kBYSTDeviceIdKey,
                                   kBYSTDeviceModelKey,
                                   kBYSTMACKey,
                                   kBYSTMobileOperatorKey,
                                   kBYSTSDKVersionKey,
                                   kBYSTSystemNameKey,
                                   kBYSTSystemVersionKey];
    
    _fieldTypesOfBaseInfoTable = @[@"integer",
                                   @"varchar(255)",
                                   @"varchar(255)",
                                   @"varchar(255)",
                                   @"varchar(255)",
                                   @"varchar(255)",
                                   @"varchar(255)",
                                   @"varchar(255)",
                                   @"varchar(255)",
                                   @"varchar(255)",
                                   @"varchar(255)",
                                   @"varchar(255)",
                                   @"varchar(255)",
                                   @"varchar(255)"];
    
    //拼接创建表语句@"create table if not exists BaseInfo (ID integer PRIMARY KEY autoincrement, ApplicationChannel varchar(255), ApplicationKey varchar(255), ApplicationName varchar(255), ApplicationPackageName varchar(255), ApplicationVersion varchar(255), DeviceBrand varchar(255), DeviceId varchar(255), DeviceModel varchar(255), MAC varchar(255), MobileOperator varchar(255), SDKVersion varchar(255), SystemName varchar(255), SystemVersion varchar(255))"
    NSString *sqlOfCreateBaseInfoTable = [self getCreateTableSqlStringWithTableName:_tableNameOfBaseInfoTable fieldNames:_fieldNamesOfBaseInfoTable fieldTypes:_fieldTypesOfBaseInfoTable];
    
    [_dbQueue  inDatabase:^(BYStatDatabase * _Nonnull db) {
        //执行sql语句
        if ([db executeStatements:sqlOfCreateBaseInfoTable]) {
            BYStatLog(@"createBaseInfoTable success");
        }else{
            BYStatLog(@"createBaseInfoTable failure");
        }
    }];
}

/**
 创建ApplicationInfoTable
 */
-(void)createApplicationInfoTable{
    _tableNameOfApplicationInfoTable = @"ApplicationInfo";
    _fieldNamesOfApplicationInfoTable = @[kBYSTIDKey, kBYSTApplicationOpenTimeKey, kBYSTApplicationCloseTimeKey, kBYSTAdditionalInfoKey];
    _fieldTypesOfApplicationInfoTable = @[@"integer", @"timestamp", @"timestamp", @"blob"];
    
    //拼接创建表语句@"create table if not exists ApplicationInfo (ID integer PRIMARY KEY autoincrement, ApplicationOpenTime timestamp, ApplicationCloseTIme timestamp, AdditionalInfo blob)"
    NSString *sqlOfCreateApplicationInfoTable = [self getCreateTableSqlStringWithTableName:_tableNameOfApplicationInfoTable fieldNames:_fieldNamesOfApplicationInfoTable fieldTypes:_fieldTypesOfApplicationInfoTable];
    
    [_dbQueue  inDatabase:^(BYStatDatabase * _Nonnull db) {
        //执行sql语句
        if ([db executeStatements:sqlOfCreateApplicationInfoTable]) {
            BYStatLog(@"createApplicationInfoTable success");
        }else{
            BYStatLog(@"createApplicationInfoTable failure");
        }
    }];
    
}

/**
 创建AccountInfoTable
 */
-(void)createAccountInfoTable{
    _tableNameOfAccountInfoTable = @"AccountInfo";
    _fieldNamesOfAccountInfoTable = @[kBYSTIDKey, kBYSTUserIdKey, kBYSTProviderKey, kBYSTSignInTimeKey, kBYSTSignOffTimeKey, kBYSTAdditionalInfoKey];
    _fieldTypesOfAccountInfoTable = @[@"integer", @"varchar(255)", @"varchar(255)", @"timestamp", @"timestamp", @"blob"];
    
    //拼接创建表语句@"create table if not exists AccountInfo (ID integer PRIMARY KEY autoincrement, UserId varchar(255), Provider varchar(255), SignInTime timestamp, SignOffTime timestamp, AdditionalInfo blob)"
    NSString *sqlOfCreateAccountInfoTable = [self getCreateTableSqlStringWithTableName:_tableNameOfAccountInfoTable fieldNames:_fieldNamesOfAccountInfoTable fieldTypes:_fieldTypesOfAccountInfoTable];
    
    [_dbQueue  inDatabase:^(BYStatDatabase * _Nonnull db) {
        //执行sql语句
        if ([db executeStatements:sqlOfCreateAccountInfoTable]) {
            BYStatLog(@"createAccountInfoTable success");
        }else{
            BYStatLog(@"createAccountInfoTable failure");
        }
    }];
}

/**
 创建PageInfoTable
 */
-(void)createPageInfoTable{
    _tableNameOfPageInfoTable = @"PageInfo";
    _fieldNamesOfPageInfoTable = @[kBYSTIDKey, kBYSTPageIdKey, kBYSTPageOpenTimeKey, kBYSTPageCloseTimeKey, kBYSTAdditionalInfoKey];
    _fieldTypesOfPageInfoTable = @[@"integer", @"varchar(255)", @"timestamp", @"timestamp", @"blob"];
    
    //拼接创建表语句@"create table if not exists PageInfo (ID integer PRIMARY KEY autoincrement, PageId varchar(255), PageOpenTime timestamp, PageCloseTime timestamp, AdditionalInfo blob)"
    NSString *sqlOfCreatePageInfoTable = [self getCreateTableSqlStringWithTableName:_tableNameOfPageInfoTable fieldNames:_fieldNamesOfPageInfoTable fieldTypes:_fieldTypesOfPageInfoTable];
    
    [_dbQueue  inDatabase:^(BYStatDatabase * _Nonnull db) {
        //执行sql语句
        if ([db executeStatements:sqlOfCreatePageInfoTable]) {
            BYStatLog(@"createPageInfoTable success");
        }else{
            BYStatLog(@"createPageInfoTable failure");
        }
    }];
}

/**
 创建EventInfoTable
 */
-(void)createEventInfoTable{
    _tableNameOfEventInfoTable = @"EventInfo";
    _fieldNamesOfEventInfoTable = @[kBYSTIDKey, kBYSTEventIdKey, kBYSTEventHappenTimeKey, kBYSTAdditionalInfoKey];
    _fieldTypesOfEventInfoTable = @[@"integer", @"varchar(255)", @"timestamp", @"blob"];
    
    //拼接创建表语句@"create table if not exists EventInfo (ID integer PRIMARY KEY autoincrement, EventId varchar(255), EventHappenTime timestamp, AdditionalInfo blob)"
    NSString *sqlOfCreateEventInfoTable = [self getCreateTableSqlStringWithTableName:_tableNameOfEventInfoTable fieldNames:_fieldNamesOfEventInfoTable fieldTypes:_fieldTypesOfEventInfoTable];
    
    [_dbQueue  inDatabase:^(BYStatDatabase * _Nonnull db) {
        //执行sql语句
        if ([db executeStatements:sqlOfCreateEventInfoTable]) {
            BYStatLog(@"createEventInfoTable success");
        }else{
            BYStatLog(@"createEventInfoTable failure");
        }
    }];
}

/**
 创建PositionInfoTable
 */
-(void)createPositionInfoTable{
    _tableNameOfPositionInfoTable = @"PositionInfo";
    _fieldNamesOfPositionInfoTable = @[kBYSTIDKey, kBYSTLongitudeKey, kBYSTLatitudeKey, kBYSTPositionChangeTimeKey, kBYSTAdditionalInfoKey];
    _fieldTypesOfPositionInfoTable = @[@"integer", @"varchar(255)", @"varchar(255)", @"timestamp", @"blob"];
    
    //拼接创建表语句@"create table if not exists PositionInfo (ID integer PRIMARY KEY autoincrement, Longitude varchar(255), Latitude varchar(255), PositionChangeTime timestamp, AdditionalInfo blob)"
    NSString *sqlOfCreatePositionInfoTable = [self getCreateTableSqlStringWithTableName:_tableNameOfPositionInfoTable fieldNames:_fieldNamesOfPositionInfoTable fieldTypes:_fieldTypesOfPositionInfoTable];
    
    [_dbQueue  inDatabase:^(BYStatDatabase * _Nonnull db) {
        //执行sql语句
        if ([db executeStatements:sqlOfCreatePositionInfoTable]) {
            BYStatLog(@"createPositionInfoTable success");
        }else{
            BYStatLog(@"createPositionInfoTable failure");
        }
    }];
    
}

/**
 创建NetworkInfoTable
 */
-(void)createNetworkInfoTable{
    _tableNameOfNetworkInfoTable = @"NetworkInfo";
    _fieldNamesOfNetworkInfoTable = @[kBYSTIDKey, kBYSTNetworkTypeKey, kBYSTNetworkChangeTimeKey, kBYSTAdditionalInfoKey];
    _fieldTypesOfNetworkInfoTable = @[@"integer", @"varchar(255)", @"timestamp", @"blob"];
    
    //拼接创建表语句@"create table if not exists NetworkInfo (ID integer PRIMARY KEY autoincrement, NetworkType varchar(255), NetworkChangeTime timestamp, AdditionalInfo blob)"
    NSString *sqlOfCreateNetworkInfoTable = [self getCreateTableSqlStringWithTableName:_tableNameOfNetworkInfoTable fieldNames:_fieldNamesOfNetworkInfoTable fieldTypes:_fieldTypesOfNetworkInfoTable];
    
    [_dbQueue  inDatabase:^(BYStatDatabase * _Nonnull db) {
        //执行sql语句
        if ([db executeStatements:sqlOfCreateNetworkInfoTable]) {
            BYStatLog(@"createNetworkInfoTable success");
        }else{
            BYStatLog(@"createNetworkInfoTable failure");
        }
    }];
}


/**
 获取创建表sql语句

 @param tableName 表名
 @param fieldNames 字段数组
 @param fieldTypes 字段类型数组
 @return 创建表sql语句
 */
-(NSString*)getCreateTableSqlStringWithTableName:(NSString*)tableName fieldNames:(NSArray*)fieldNames fieldTypes:(NSArray*)fieldTypes{
    
    NSString *sqlOfCreateBaseInfoTable = [NSString stringWithFormat:@"create table if not exists %@ (", tableName];
    NSUInteger fieldCout = fieldNames.count;
    for (int i = 0; i < fieldCout; i++) {
        if (i == 0) {//第一个字段
            sqlOfCreateBaseInfoTable = [sqlOfCreateBaseInfoTable stringByAppendingFormat:@"%@ %@ PRIMARY KEY autoincrement, ", fieldNames[i], fieldTypes[i]];
        }else{      //其余字段
            if (i != fieldCout - 1) {//最后一个字段
                sqlOfCreateBaseInfoTable = [sqlOfCreateBaseInfoTable stringByAppendingFormat:@"%@ %@, ", fieldNames[i], fieldTypes[i]];
            }else{
                sqlOfCreateBaseInfoTable = [sqlOfCreateBaseInfoTable stringByAppendingFormat:@"%@ %@)", fieldNames[i], fieldTypes[i]];
            }
        }
        
    }
    
    return sqlOfCreateBaseInfoTable;
}

/**
 获取插入sql语句

 @param tableName 表名
 @param fieldNames 字段数组
 @return 插入sql语句
 */
-(NSString*)getInsertSqlStringWithTableName:(NSString*)tableName fieldNames:(NSArray*)fieldNames{
    
    NSString *sqlInsert = [NSString stringWithFormat:@"insert into %@ (", tableName];
    NSUInteger fieldCout = fieldNames.count;
    for (int i = 1; i < fieldCout; i++) {
        if (i != fieldCout - 1) {
            sqlInsert = [sqlInsert stringByAppendingFormat:@"%@, ", fieldNames[i]];
        }else{
            sqlInsert = [sqlInsert stringByAppendingFormat:@"%@) values (", fieldNames[i]];
        }
    }
    
    for (int i = 1; i < fieldCout; i++) {
        if (i != fieldCout - 1) {
            sqlInsert = [sqlInsert stringByAppendingFormat:@"?, "];
        }else{
            sqlInsert = [sqlInsert stringByAppendingFormat:@"?)"];
        }
    }
    
    return sqlInsert;
}

/**
 删除库中某天前的记录
 */
-(void)deleteRecordOfSomeDaysAgo:(NSNumber*)someDays{
    
    NSTimeInterval interval = someDays.intValue * 24 * 60 * 60;
    NSDate *someDaysAgo = [NSDate dateWithTimeIntervalSinceNow:-interval];
    NSTimeInterval timeIntervalSince1970 = [someDaysAgo timeIntervalSince1970];
    
    //删除应用信息表中某天前的记录
    [self deleteRecordOfSomeDaysAgoFromApplicationInfoTable:timeIntervalSince1970];
    //删除账号信息表中某天前的记录
    [self deleteRecordOfSomeDaysAgoFromAccountInfoTable:timeIntervalSince1970];
    //删除页面信息表中某天前的记录
    [self deleteRecordOfSomeDaysAgoFromPageInfoTable:timeIntervalSince1970];
    //删除事件信息表中某天前的记录
    [self deleteRecordOfSomeDaysAgoFromEventInfoTable:timeIntervalSince1970];
    //删除位置信息表中某天前的记录
    [self deleteRecordOfSomeDaysAgoFromPositionInfoTable:timeIntervalSince1970];
    //删除网络信息表中某天前的记录
    [self deleteRecordOfSomeDaysAgoFromNetworkInfoTable:timeIntervalSince1970];
}

@end


//基本信息表操作协调层：针对该表的操作
@implementation BYStatSqliteHandleCoordinator (BaseInfoTable)

/**
 查询基本信息表
 @param param 包含操作回调
 */
-(void)queryRecordFromBaseInfoTableWithParam:(NSDictionary*)param{
    [_dbQueue inDatabase:^(BYStatDatabase * _Nonnull db) {
        //拼接查询语句
        NSString *sqlSelect = [NSString stringWithFormat:@"select * from %@ order by id desc limit 0,1", _tableNameOfBaseInfoTable];
        //执行sql语句
        BYStatResultSet *set = [db executeQuery:sqlSelect];
        
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        if ([set next] && set.resultDictionary) {
            [result addEntriesFromDictionary:set.resultDictionary];
        }
        
        //关闭ResultSet
        [set close];
        
        //主线程回调
        dispatch_async(dispatch_get_main_queue(), ^{
            sqliteHandleCallback callback = [param objectForKey:kBYSTSqliteHandleCallback];
            if (callback) {
                callback(BYStatInfoTableTypeOfBaseInfo, result);
            }
        });
    }];
}

/**
 插入记录到基本信息表
 @param param 参数信息
 */
-(void)insertRecordToBaseInfoTableWithParam:(NSDictionary*)param{
    //获取字段值
    NSString *ApplicationChannel = [param objectForKey:kBYSTApplicationChannelKey];
    NSString *ApplicationKey = [param objectForKey:kBYSTApplicationKeyKey];
    NSString *ApplicationName = [param objectForKey:kBYSTApplicationNameKey];
    NSString *ApplicationPackageName = [param objectForKey:kBYSTApplicationPackageNameKey];
    NSString *ApplicationVersion = [param objectForKey:kBYSTApplicationVersionKey];
    NSString *DeviceBrand = [param objectForKey:kBYSTDeviceBrandKey];
    NSString *DeviceId = [param objectForKey:kBYSTDeviceIdKey];
    NSString *DeviceModel = [param objectForKey:kBYSTDeviceModelKey];
    NSString *MAC = [param objectForKey:kBYSTMACKey];
    NSString *MobileOperator = [param objectForKey:kBYSTMobileOperatorKey];
    NSString *SDKVersion = [param objectForKey:kBYSTSDKVersionKey];
    NSString *SystemName = [param objectForKey:kBYSTSystemNameKey];
    NSString *SystemVersion = [param objectForKey:kBYSTSystemVersionKey];
    
    //先删除表中记录
    NSString *sqlDelete = [NSString stringWithFormat:@"delete from %@", _tableNameOfBaseInfoTable];
    
    //再插入新记录
    NSString *sqlInsert = [NSString stringWithFormat: @"insert into %@ (", _tableNameOfBaseInfoTable];
    for (int i = 1; i < _fieldNamesOfBaseInfoTable.count; i++) {
        if (i != _fieldNamesOfBaseInfoTable.count - 1) {
            sqlInsert = [sqlInsert stringByAppendingFormat:@"%@, ", _fieldNamesOfBaseInfoTable[i]];
        }else{
            sqlInsert = [sqlInsert stringByAppendingFormat:@"%@) values (", _fieldNamesOfBaseInfoTable[i]];
        }
    }
    
    for (int i = 1; i < _fieldNamesOfBaseInfoTable.count; i++) {
        if (i != _fieldNamesOfBaseInfoTable.count - 1) {
            sqlInsert = [sqlInsert stringByAppendingFormat:@"'%%@', "];
        }else{
            sqlInsert = [sqlInsert stringByAppendingFormat:@"'%%@')"];
        }
    }
    
    sqlInsert = [NSString stringWithFormat:sqlInsert, ApplicationChannel, ApplicationKey, ApplicationName, ApplicationPackageName, ApplicationVersion, DeviceBrand, DeviceId, DeviceModel, MAC, MobileOperator, SDKVersion, SystemName, SystemVersion];
    
    NSString *statements = [NSString stringWithFormat:@"%@;%@;", sqlDelete, sqlInsert];
    //执行sql语句
    [_dbQueue inTransaction:^(BYStatDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        if ([db executeStatements:statements]) {
            BYStatLog(@"insertRecordToBaseInfoTableWithParam success");
        }else{
            *rollback = YES;
            //...
        }
        
    }];
    
}

@end


//应用信息表操作协调层：针对该表的操作
@implementation BYStatSqliteHandleCoordinator (ApplicationInfoTable)

/**
 插入记录到应用信息表
 @param param 参数信息
 */
-(void)insertRecordToApplicationInfoTableWithParam:(NSDictionary*)param{
    //获取字段值
    NSDate *ApplicationOpenTime = [param objectForKey:kBYSTApplicationOpenTimeKey];
    NSDate *ApplicationCloseTime = [param objectForKey:kBYSTApplicationCloseTimeKey];
    NSData *AdditionalInfo = [NSJSONSerialization dataWithJSONObject:[param objectForKey:kBYSTAdditionalInfoKey] options:0 error:nil];
    
    //拼接插入语句@"insert into ApplicationInfo (ApplicationOpenTime, ApplicationCloseTime, AdditionalInfo) values (?, ?, ?)"
    NSString *sqlInsert = [self getInsertSqlStringWithTableName:_tableNameOfApplicationInfoTable fieldNames:_fieldNamesOfApplicationInfoTable];
    
    //执行sql语句
    [_dbQueue inDatabase:^(BYStatDatabase * _Nonnull db) {
        if ([db executeUpdate:sqlInsert, ApplicationOpenTime, ApplicationCloseTime, AdditionalInfo]) {
            BYStatLog(@"insertRecordToApplicationInfoTableWithParam success");
        }
        
    }];
    
}

/**
 更新记录到应用信息表
 @param param 参数信息
 */
-(void)updateRecordToApplicationInfoTableWithParam:(NSDictionary*)param{
    //获取字段值
    NSDate *ApplicationOpenTime = [param objectForKey:kBYSTApplicationOpenTimeKey];
    NSDate *ApplicationCloseTime = [param objectForKey:kBYSTApplicationCloseTimeKey];
    NSData *AdditionalInfo = [NSJSONSerialization dataWithJSONObject:[param objectForKey:kBYSTAdditionalInfoKey] options:0 error:nil];
    
    //拼接更新语句
    NSString *sqlUpdate = [NSString stringWithFormat:@"update %@ set %@ = ?, %@ = ? where %@ = ?",
                           _tableNameOfApplicationInfoTable, kBYSTApplicationCloseTimeKey, kBYSTAdditionalInfoKey, kBYSTApplicationOpenTimeKey];
    //执行sql语句@"update ApplicationInfo set ApplicationCloseTime = ?, AdditionalInfo = ? where ApplicationOpenTime = ?"
    [_dbQueue inDatabase:^(BYStatDatabase * _Nonnull db) {
        if ([db executeUpdate:sqlUpdate, ApplicationCloseTime, AdditionalInfo, ApplicationOpenTime]) {
            BYStatLog(@"updateRecordToApplicationInfoTableWithParam success");
        }
    }];
    
}

/**
 查询应用信息表
 @param param 包含操作回调
 */
-(void)queryRecordFromApplicationInfoTableWithParam:(NSDictionary*)param{
    [_dbQueue inDatabase:^(BYStatDatabase * _Nonnull db) {
        //拼接查询语句
        NSString *sqlSelect = [NSString stringWithFormat:@"select * from %@", _tableNameOfApplicationInfoTable];
        //执行sql语句
        BYStatResultSet *set = [db executeQuery:sqlSelect];
        
        NSMutableArray *result = [NSMutableArray array];
        while ([set next]) {
            if (set.resultDictionary) {
               [result addObject:set.resultDictionary];
            }
        }
        
        //关闭ResultSet
        [set close];
        
        //主线程回调
        dispatch_async(dispatch_get_main_queue(), ^{
            sqliteHandleCallback callback = [param objectForKey:kBYSTSqliteHandleCallback];
            if (callback) {
                callback(BYStatInfoTableTypeOfApplicationInfo, result);
            }
        });
    }];
}

/**
 删除应用信息表中的记录
 @param param 参数信息
 */
-(void)deleteRecordFromApplicationInfoTableWithParam:(NSArray*)param{
    //@[@"ID", @"ApplicationOpenTime", @"ApplicationCloseTime", @"AdditionalInfo"];
    if (param.count > 0) {
        NSMutableArray *IDArray = [NSMutableArray array];
        for (NSDictionary *item in param) {
            int ID = [[item objectForKey:kBYSTIDKey]intValue];
            [IDArray addObject:[NSString stringWithFormat:@"%d", ID]];
        }
        NSString *values = [IDArray componentsJoinedByString:@","];
        
        //拼接删除语句:delete from xxxInfo where ID in (7, 8, 9)
        NSString *sqlDelete = [NSString stringWithFormat:@"delete from %@ where ID in (%@)", _tableNameOfApplicationInfoTable, values];
        
        //执行sql语句
        [_dbQueue inDatabase:^(BYStatDatabase * _Nonnull db) {
            if ([db executeUpdate:sqlDelete]) {
                BYStatLog(@"deleteRecordFromApplicationInfoTableWithParam success");
            }
        }];
    }
}

/**
 删除应用信息表中某天前的记录
 @param timestamp 某天前的时间戳
 */
-(void)deleteRecordOfSomeDaysAgoFromApplicationInfoTable:(NSTimeInterval)timestamp{
    
    //拼接删除语句:delete from xxxInfo where ApplicationOpenTime <= 1516259458
    NSString *sqlDelete = [NSString stringWithFormat:@"delete from %@ where ApplicationOpenTime <= %f", _tableNameOfApplicationInfoTable, timestamp];
    
    //执行sql语句
    [_dbQueue inDatabase:^(BYStatDatabase * _Nonnull db) {
        if ([db executeUpdate:sqlDelete]) {
            BYStatLog(@"deleteRecordOfSomeDaysAgoFromApplicationInfoTable success");
        }
    }];
    
}

@end

//账户信息表操作协调层：针对该表的操作
@implementation BYStatSqliteHandleCoordinator (AccountInfoTable)

/**
 插入记录到账号信息表
 @param param 参数信息
 */
-(void)insertRecordToAccountInfoTableWithParam:(NSDictionary*)param{
    //@[@"ID", @"UserId", @"Provider", @"SignInTime", @"SignOffTime", @"AdditionalInfo"];
    //获取字段值
    NSString *UserId = [param objectForKey:kBYSTUserIdKey];
    NSString *Provider = [param objectForKey:kBYSTProviderKey];
    NSDate *SignInTime = [param objectForKey:kBYSTSignInTimeKey];
    NSDate *SignOffTime = [param objectForKey:kBYSTSignOffTimeKey];
    NSData *AdditionalInfo = [NSJSONSerialization dataWithJSONObject:[param objectForKey:kBYSTAdditionalInfoKey] options:0 error:nil];
    
    //拼接插入语句@""
    NSString *sqlInsert = [self getInsertSqlStringWithTableName:_tableNameOfAccountInfoTable fieldNames:_fieldNamesOfAccountInfoTable];
    
    //执行sql语句
    [_dbQueue inDatabase:^(BYStatDatabase * _Nonnull db) {
        if ([db executeUpdate:sqlInsert, UserId, Provider, SignInTime, SignOffTime, AdditionalInfo]) {
            BYStatLog(@"insertRecordToAccountInfoTableWithParam success");
        }
        
    }];
}

/**
 更新记录到账号信息表
 @param param 参数信息
 */
-(void)updateRecordToAccountInfoTableWithParam:(NSDictionary*)param{
    //@[@"ID", @"UserId", @"Provider", @"SignInTime", @"SignOffTime", @"AdditionalInfo"];
    //获取字段值
    NSString *UserId = [param objectForKey:kBYSTUserIdKey];
    NSString *Provider = [param objectForKey:kBYSTProviderKey];
    NSDate *SignInTime = [param objectForKey:kBYSTSignInTimeKey];
    NSDate *SignOffTime = [param objectForKey:kBYSTSignOffTimeKey];
    NSData *AdditionalInfo = [NSJSONSerialization dataWithJSONObject:[param objectForKey:kBYSTAdditionalInfoKey] options:0 error:nil];
    
    //拼接更新语句
    NSString *sqlUpdate = [NSString stringWithFormat:@"update %@ set %@ = ?, %@ = ? where %@ = ? and %@ = ? and %@ = ?",
                           _tableNameOfAccountInfoTable, kBYSTSignOffTimeKey, kBYSTAdditionalInfoKey, kBYSTUserIdKey, kBYSTProviderKey, kBYSTSignInTimeKey];
    
    //执行sql语句@""
    [_dbQueue inDatabase:^(BYStatDatabase * _Nonnull db) {
        if ([db executeUpdate:sqlUpdate, SignOffTime, AdditionalInfo, UserId, Provider, SignInTime]) {
            BYStatLog(@"updateRecordToAccountInfoTableWithParam success");
        }
    }];
}

/**
 查询账号信息表
 @param param 包含操作回调
 */
-(void)queryRecordFromAccountInfoTableWithParam:(NSDictionary*)param{
    [_dbQueue inDatabase:^(BYStatDatabase * _Nonnull db) {
        //@[@"ID", @"UserId", @"Provider", @"SignInTime", @"SignOffTime", @"AdditionalInfo"];
        //拼接查询语句
        NSString *sqlSelect = [NSString stringWithFormat:@"select * from %@", _tableNameOfAccountInfoTable];
        //执行sql语句
        BYStatResultSet *set = [db executeQuery:sqlSelect];
        
        NSMutableArray *result = [NSMutableArray array];
        while ([set next]) {
            if (set.resultDictionary) {
                [result addObject:set.resultDictionary];
            }
        }
        
        //关闭ResultSet
        [set close];
        
        //主线程回调
        dispatch_async(dispatch_get_main_queue(), ^{
            sqliteHandleCallback callback = [param objectForKey:kBYSTSqliteHandleCallback];
            if (callback) {
                callback(BYStatInfoTableTypeOfAccountInfo, result);
            }
        });
    }];
}

/**
 查询账号信息表最后一条记录
 @param param 包含操作回调
 */
-(void)queryLastRecordFromAccountInfoTableWithParam:(NSDictionary*)param{
    [_dbQueue inDatabase:^(BYStatDatabase * _Nonnull db) {
        //@[@"ID", @"UserId", @"Provider", @"SignInTime", @"SignOffTime", @"AdditionalInfo"];
        //拼接查询语句@"select * from PageInfo order by id desc limit 0,1"
        NSString *sqlSelect = [NSString stringWithFormat:@"select * from %@ order by id desc limit 0,1", _tableNameOfAccountInfoTable];
        //执行sql语句
        BYStatResultSet *set = [db executeQuery:sqlSelect];
        
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        if ([set next] && set.resultDictionary) {
            [result addEntriesFromDictionary:set.resultDictionary];
        }
        
        //关闭ResultSet
        [set close];
        
        //主线程回调
        dispatch_async(dispatch_get_main_queue(), ^{
            sqliteHandleCallback callback = [param objectForKey:kBYSTSqliteHandleCallback];
            if (callback) {
               callback(BYStatInfoTableTypeOfAccountInfo, result);
            }
        });
    }];
}

/**
 删除账号信息表中的记录
 @param param 参数信息
 */
-(void)deleteRecordFromAccountInfoTableWithParam:(NSArray*)param{
    //@[@"ID", @"UserId", @"SignInTime", @"SignOffTime", @"AdditionalInfo"];
    if (param.count > 0) {
        
        NSMutableArray *IDArray = [NSMutableArray array];
        for (NSDictionary *item in param) {
            int ID = [[item objectForKey:kBYSTIDKey]intValue];
            [IDArray addObject:[NSString stringWithFormat:@"%d", ID]];
        }
        NSString *values = [IDArray componentsJoinedByString:@","];
        
        //拼接删除语句:delete from xxxInfo where ID in (7, 8, 9)
        NSString *sqlDelete = [NSString stringWithFormat:@"delete from %@ where ID in (%@)", _tableNameOfAccountInfoTable, values];
        
        //执行sql语句
        [_dbQueue inDatabase:^(BYStatDatabase * _Nonnull db) {
            if ([db executeUpdate:sqlDelete]) {
                BYStatLog(@"deleteRecordFromAccountInfoTableWithParam success");
            }
        }];
    }
}

/**
 删除账号信息表中某天前的记录
 @param timestamp 某天前的时间戳
 */
-(void)deleteRecordOfSomeDaysAgoFromAccountInfoTable:(NSTimeInterval)timestamp{
    
    //拼接删除语句:delete from xxxInfo where SignInTime <= 1516259458
    NSString *sqlDelete = [NSString stringWithFormat:@"delete from %@ where SignInTime <= %f", _tableNameOfAccountInfoTable, timestamp];
    
    //执行sql语句
    [_dbQueue inDatabase:^(BYStatDatabase * _Nonnull db) {
        if ([db executeUpdate:sqlDelete]) {
            BYStatLog(@"deleteRecordOfSomeDaysAgoFromAccountInfoTable success");
        }
    }];
}

@end

//页面信息表操作协调层：针对该表的操作
@implementation BYStatSqliteHandleCoordinator (PageInfoTable)

/**
 插入记录到页面信息表
 @param param 参数信息
 */
-(void)insertRecordToPageInfoTableWithParam:(NSDictionary*)param{
    //@[@"ID", @"PageId", @"PageOpenTime", @"PageCloseTime", @"AdditionalInfo"];
    //获取字段值
    NSString *PageId = [param objectForKey:kBYSTPageIdKey];
    NSDate *PageOpenTime = [param objectForKey:kBYSTPageOpenTimeKey];
    NSDate *PageCloseTime = [param objectForKey:kBYSTPageCloseTimeKey];
    NSData *AdditionalInfo = [NSJSONSerialization dataWithJSONObject:[param objectForKey:kBYSTAdditionalInfoKey] options:0 error:nil];
    
    //拼接插入语句@""
    NSString *sqlInsert = [self getInsertSqlStringWithTableName:_tableNameOfPageInfoTable fieldNames:_fieldNamesOfPageInfoTable];
    
    //执行sql语句
    [_dbQueue inDatabase:^(BYStatDatabase * _Nonnull db) {
        if ([db executeUpdate:sqlInsert, PageId, PageOpenTime, PageCloseTime, AdditionalInfo]) {
            BYStatLog(@"insertRecordToPageInfoTableWithParam success");
        }
        
    }];
}

/**
 更新记录到页面信息表
 @param param 参数信息
 */
-(void)updateRecordToPageInfoTableWithParam:(NSDictionary*)param{
    //@[@"ID", @"PageId", @"PageOpenTime", @"PageCloseTime", @"AdditionalInfo"];
    //获取字段值
    NSString *PageId = [param objectForKey:kBYSTPageIdKey];
    NSDate *PageOpenTime = [param objectForKey:kBYSTPageOpenTimeKey];
    NSDate *PageCloseTime = [param objectForKey:kBYSTPageCloseTimeKey];
    NSData *AdditionalInfo = [NSJSONSerialization dataWithJSONObject:[param objectForKey:kBYSTAdditionalInfoKey] options:0 error:nil];
    
    //拼接更新语句
    NSString *sqlUpdate = [NSString stringWithFormat:@"update %@ set %@ = ?, %@ = ? where %@ = ? and %@ = ?",
                           _tableNameOfPageInfoTable, kBYSTPageCloseTimeKey, kBYSTAdditionalInfoKey, kBYSTPageIdKey, kBYSTPageOpenTimeKey];
    
    //执行sql语句@""
    [_dbQueue inDatabase:^(BYStatDatabase * _Nonnull db) {
        if ([db executeUpdate:sqlUpdate, PageCloseTime, AdditionalInfo, PageId, PageOpenTime]) {
            BYStatLog(@"updateRecordToPageInfoTableWithParam success");
        }
    }];
    
}

/**
 查询页面信息表
 @param param 包含操作回调
 */
-(void)queryRecordFromPageInfoTableWithParam:(NSDictionary*)param{
    [_dbQueue inDatabase:^(BYStatDatabase * _Nonnull db) {
        //@[@"ID", @"PageId", @"PageOpenTime", @"PageCloseTime", @"AdditionalInfo"];
        //拼接查询语句
        NSString *sqlSelect = [NSString stringWithFormat:@"select * from %@", _tableNameOfPageInfoTable];
        //执行sql语句
        BYStatResultSet *set = [db executeQuery:sqlSelect];
        
        NSMutableArray *result = [NSMutableArray array];
        while ([set next]) {
            if (set.resultDictionary) {
                [result addObject:set.resultDictionary];
            }
        }
        
        //关闭ResultSet
        [set close];
        
        //主线程回调
        dispatch_async(dispatch_get_main_queue(), ^{
            sqliteHandleCallback callback = [param objectForKey:kBYSTSqliteHandleCallback];
            if (callback) {
                callback(BYStatInfoTableTypeOfPageInfo, result);
            }
        });
    }];
}

/**
 删除页面信息表中的记录
 @param param 参数信息
 */
-(void)deleteRecordFromPageInfoTableWithParam:(NSArray*)param{
    //@[@"ID", @"PageId", @"PageOpenTime", @"PageCloseTime", @"AdditionalInfo"];
    if (param.count > 0) {
        
        NSMutableArray *IDArray = [NSMutableArray array];
        for (NSDictionary *item in param) {
            int ID = [[item objectForKey:kBYSTIDKey]intValue];
            [IDArray addObject:[NSString stringWithFormat:@"%d", ID]];
        }
        NSString *values = [IDArray componentsJoinedByString:@","];
        
        //拼接删除语句:delete from PageInfo where ID in (7, 8, 9)
        NSString *sqlDelete = [NSString stringWithFormat:@"delete from %@ where ID in (%@)", _tableNameOfPageInfoTable, values];
        
        //执行sql语句
        [_dbQueue inDatabase:^(BYStatDatabase * _Nonnull db) {
            if ([db executeUpdate:sqlDelete]) {
                BYStatLog(@"deleteRecordFromPageInfoTableWithParam success");
            }
        }];
    }
}

/**
 删除页面信息表中某天前的记录
 @param timestamp 某天前的时间戳
 */
-(void)deleteRecordOfSomeDaysAgoFromPageInfoTable:(NSTimeInterval)timestamp{
    
    //拼接删除语句:delete from xxxInfo where PageOpenTime <= 1516259458
    NSString *sqlDelete = [NSString stringWithFormat:@"delete from %@ where PageOpenTime <= %f", _tableNameOfPageInfoTable, timestamp];
    
    //执行sql语句
    [_dbQueue inDatabase:^(BYStatDatabase * _Nonnull db) {
        if ([db executeUpdate:sqlDelete]) {
            BYStatLog(@"deleteRecordOfSomeDaysAgoFromPageInfoTable success");
        }
    }];
}

@end

//事件信息表操作协调层：针对该表的操作
@implementation BYStatSqliteHandleCoordinator (EventInfoTable)

/**
 插入记录到事件信息表
 @param param 参数信息
 */
-(void)insertRecordToEventInfoTableWithParam:(NSDictionary*)param{
    //@[@"ID", @"EventId", @"EventHappenTime", @"AdditionalInfo"];
    //获取字段值
    NSString *EventId = [param objectForKey:kBYSTEventIdKey];
    NSDate *EventHappenTime = [param objectForKey:kBYSTEventHappenTimeKey];
    NSData *AdditionalInfo = [NSJSONSerialization dataWithJSONObject:[param objectForKey:kBYSTAdditionalInfoKey] options:0 error:nil];
    
    //拼接插入语句@""
    NSString *sqlInsert = [self getInsertSqlStringWithTableName:_tableNameOfEventInfoTable fieldNames:_fieldNamesOfEventInfoTable];
    
    //执行sql语句
    [_dbQueue inDatabase:^(BYStatDatabase * _Nonnull db) {
        if ([db executeUpdate:sqlInsert, EventId, EventHappenTime, AdditionalInfo]) {
            BYStatLog(@"insertRecordToEventInfoTableWithParam success");
        }
        
    }];
}

/**
 查询事件信息表
 @param param 包含操作回调
 */
-(void)queryRecordFromEventInfoTableWithParam:(NSDictionary*)param{
    [_dbQueue inDatabase:^(BYStatDatabase * _Nonnull db) {
        //@[@"ID", @"EventId", @"EventHappenTime", @"AdditionalInfo"];
        //拼接查询语句
        NSString *sqlSelect = [NSString stringWithFormat:@"select * from %@", _tableNameOfEventInfoTable];
        //执行sql语句
        BYStatResultSet *set = [db executeQuery:sqlSelect];
        
        NSMutableArray *result = [NSMutableArray array];
        while ([set next]) {
            if (set.resultDictionary) {
                [result addObject:set.resultDictionary];
            }
        }
        
        //关闭ResultSet
        [set close];
        
        //主线程回调
        dispatch_async(dispatch_get_main_queue(), ^{
            sqliteHandleCallback callback = [param objectForKey:kBYSTSqliteHandleCallback];
            if (callback) {
                callback(BYStatInfoTableTypeOfEventInfo, result);
            }
        });
    }];
}

/**
 删除事件信息表中的记录
 @param param 参数信息
 */
-(void)deleteRecordFromEventInfoTableWithParam:(NSArray*)param{
    //@[@"ID", @"EventId", @"EventHappenTime", @"AdditionalInfo"];
    if (param.count > 0) {
        
        NSMutableArray *IDArray = [NSMutableArray array];
        for (NSDictionary *item in param) {
            int ID = [[item objectForKey:kBYSTIDKey]intValue];
            [IDArray addObject:[NSString stringWithFormat:@"%d", ID]];
        }
        NSString *values = [IDArray componentsJoinedByString:@","];
        
        //拼接删除语句:delete from xxxInfo where ID in (7, 8, 9)
        NSString *sqlDelete = [NSString stringWithFormat:@"delete from %@ where ID in (%@)", _tableNameOfEventInfoTable, values];
        
        //执行sql语句
        [_dbQueue inDatabase:^(BYStatDatabase * _Nonnull db) {
            if ([db executeUpdate:sqlDelete]) {
                BYStatLog(@"deleteRecordFromEventInfoTableWithParam success");
            }
        }];
    }
}

/**
 删除事件信息表中某天前的记录
 @param timestamp 某天前的时间戳
 */
-(void)deleteRecordOfSomeDaysAgoFromEventInfoTable:(NSTimeInterval)timestamp{
    
    //拼接删除语句:delete from xxxInfo where EventHappenTime <= 1516259458
    NSString *sqlDelete = [NSString stringWithFormat:@"delete from %@ where EventHappenTime <= %f", _tableNameOfEventInfoTable, timestamp];
    
    //执行sql语句
    [_dbQueue inDatabase:^(BYStatDatabase * _Nonnull db) {
        if ([db executeUpdate:sqlDelete]) {
            BYStatLog(@"deleteRecordOfSomeDaysAgoFromEventInfoTable success");
        }
    }];
}

@end


//位置信息表操作协调层：针对该表的操作
@implementation BYStatSqliteHandleCoordinator (PositionInfoTable)

/**
 插入记录到位置信息表
 @param param 参数信息
 */
-(void)insertRecordToPositionInfoTableWithParam:(NSDictionary*)param{
    //@[@"ID", @"Longitude", @"Latitude", @"PositionChangeTime", @"AdditionalInfo"];
    //获取字段值
    NSString *Longitude = [param objectForKey:kBYSTLongitudeKey];
    NSString *Latitude = [param objectForKeyedSubscript:kBYSTLatitudeKey];
    NSDate *PositionChangeTime = [param objectForKey:kBYSTPositionChangeTimeKey];
    NSData *AdditionalInfo = [NSJSONSerialization dataWithJSONObject:[param objectForKey:kBYSTAdditionalInfoKey] options:0 error:nil];
    
    //拼接插入语句@""
    NSString *sqlInsert = [self getInsertSqlStringWithTableName:_tableNameOfPositionInfoTable fieldNames:_fieldNamesOfPositionInfoTable];
    
    //执行sql语句
    [_dbQueue inDatabase:^(BYStatDatabase * _Nonnull db) {
        if ([db executeUpdate:sqlInsert, Longitude, Latitude, PositionChangeTime, AdditionalInfo]) {
            BYStatLog(@"insertRecordToPositionInfoTableWithParam success");
        }
        
    }];
}

/**
 查询位置信息表
 @param param 包含操作回调
 */
-(void)queryRecordFromPositionInfoTableWithParam:(NSDictionary*)param{
    [_dbQueue inDatabase:^(BYStatDatabase * _Nonnull db) {
        //@[@"Longitude", @"Latitude", @"PositionChangeTime", @"AdditionalInfo"];
        //拼接查询语句
        NSString *sqlSelect = [NSString stringWithFormat:@"select * from %@", _tableNameOfPositionInfoTable];
        //执行sql语句
        BYStatResultSet *set = [db executeQuery:sqlSelect];
        
        NSMutableArray *result = [NSMutableArray array];
        while ([set next]) {
            if (set.resultDictionary) {
                [result addObject:set.resultDictionary];
            }
        }
        
        //关闭ResultSet
        [set close];
        
        //主线程回调
        dispatch_async(dispatch_get_main_queue(), ^{
            sqliteHandleCallback callback = [param objectForKey:kBYSTSqliteHandleCallback];
            if (callback) {
               callback(BYStatInfoTableTypeOfPositionInfo, result);
            }
        });
    }];
}

/**
 删除位置信息表中的记录
 @param param 参数信息
 */
-(void)deleteRecordFromPositionInfoTableWithParam:(NSArray*)param{
    //@[@"Longitude", @"Latitude", @"PositionChangeTime", @"AdditionalInfo"];
    if (param.count > 0) {
        
        NSMutableArray *IDArray = [NSMutableArray array];
        for (NSDictionary *item in param) {
            int ID = [[item objectForKey:kBYSTIDKey]intValue];
            [IDArray addObject:[NSString stringWithFormat:@"%d", ID]];
        }
        NSString *values = [IDArray componentsJoinedByString:@","];
        
        //拼接删除语句:delete from xxxInfo where ID in (7, 8, 9)
        NSString *sqlDelete = [NSString stringWithFormat:@"delete from %@ where ID in (%@)", _tableNameOfPositionInfoTable, values];
        
        //执行sql语句
        [_dbQueue inDatabase:^(BYStatDatabase * _Nonnull db) {
            if ([db executeUpdate:sqlDelete]) {
                BYStatLog(@"deleteRecordFromPositionInfoTableWithParam success");
            }
        }];
    }
    
}

/**
 删除位置信息表中某天前的记录
 @param timestamp 某天前的时间戳
 */
-(void)deleteRecordOfSomeDaysAgoFromPositionInfoTable:(NSTimeInterval)timestamp{
    
    //拼接删除语句:delete from xxxInfo where PositionChangeTime <= 1516259458
    NSString *sqlDelete = [NSString stringWithFormat:@"delete from %@ where PositionChangeTime <= %f", _tableNameOfPositionInfoTable, timestamp];
    
    //执行sql语句
    [_dbQueue inDatabase:^(BYStatDatabase * _Nonnull db) {
        if ([db executeUpdate:sqlDelete]) {
            BYStatLog(@"deleteRecordOfSomeDaysAgoFromPositionInfoTable success");
        }
    }];
}

@end

//网络信息表操作协调层：针对该表的操作
@implementation BYStatSqliteHandleCoordinator (NetworkInfoTable)

/**
 插入记录到网络信息表
 @param param 参数信息
 */
-(void)insertRecordToNetworkInfoTableWithParam:(NSDictionary*)param{
    //@[@"ID", @"NetworkType", @"NetworkChangeTime", @"AdditionalInfo"];
    //获取字段值
    NSString *NetworkType = [param objectForKey:kBYSTNetworkTypeKey];
    NSDate *NetworkChangeTime = [param objectForKey:kBYSTNetworkChangeTimeKey];
    NSData *AdditionalInfo = [NSJSONSerialization dataWithJSONObject:[param objectForKey:kBYSTAdditionalInfoKey] options:0 error:nil];
    
    //拼接插入语句@""
    NSString *sqlInsert = [self getInsertSqlStringWithTableName:_tableNameOfNetworkInfoTable fieldNames:_fieldNamesOfNetworkInfoTable];
    
    //执行sql语句
    [_dbQueue inDatabase:^(BYStatDatabase * _Nonnull db) {
        if ([db executeUpdate:sqlInsert, NetworkType, NetworkChangeTime, AdditionalInfo]) {
            BYStatLog(@"insertRecordToNetworkInfoTableWithParam success");
        }
        
    }];
}

/**
 查询网络信息表
 @param param 包含操作回调
 */
-(void)queryRecordFromNetworkInfoTableWithParam:(NSDictionary*)param{
    [_dbQueue inDatabase:^(BYStatDatabase * _Nonnull db) {
        //@[@"NetworkType", @"NetworkChangeTime", @"AdditionalInfo"];
        //拼接查询语句
        NSString *sqlSelect = [NSString stringWithFormat:@"select * from %@", _tableNameOfNetworkInfoTable];
        //执行sql语句
        BYStatResultSet *set = [db executeQuery:sqlSelect];
        
        NSMutableArray *result = [NSMutableArray array];
        while ([set next]) {
            if (set.resultDictionary) {
                [result addObject:set.resultDictionary];
            }
        }
        
        //关闭ResultSet
        [set close];
        
        //主线程回调
        dispatch_async(dispatch_get_main_queue(), ^{
            sqliteHandleCallback callback = [param objectForKey:kBYSTSqliteHandleCallback];
            if (callback) {
                callback(BYStatInfoTableTypeOfNetworkInfo, result);
            }
        });
    }];
}

/**
 删除网络信息表中的记录
 @param param 参数信息
 */
-(void)deleteRecordFromNetworkInfoTableWithParam:(NSArray*)param{
    //@[@"ID", @"NetworkType", @"NetworkChangeTime", @"AdditionalInfo"];
    if (param.count > 0) {
        
        NSMutableArray *IDArray = [NSMutableArray array];
        for (NSDictionary *item in param) {
            int ID = [[item objectForKey:kBYSTIDKey]intValue];
            [IDArray addObject:[NSString stringWithFormat:@"%d", ID]];
        }
        NSString *values = [IDArray componentsJoinedByString:@","];
        
        //拼接删除语句:delete from xxxInfo where ID in (7, 8, 9)
        NSString *sqlDelete = [NSString stringWithFormat:@"delete from %@ where ID in (%@)", _tableNameOfNetworkInfoTable, values];

        //执行sql语句
        [_dbQueue inDatabase:^(BYStatDatabase * _Nonnull db) {
            if ([db executeUpdate:sqlDelete]) {
                BYStatLog(@"deleteRecordFromNetworkInfoTableWithParam success");
            }
        }];
    }
}

/**
 删除网络信息表中某天前的记录
 @param timestamp 某天前的时间戳
 */
-(void)deleteRecordOfSomeDaysAgoFromNetworkInfoTable:(NSTimeInterval)timestamp{
    
    //拼接删除语句:delete from xxxInfo where NetworkChangeTime <= 1516259458
    NSString *sqlDelete = [NSString stringWithFormat:@"delete from %@ where NetworkChangeTime <= %f", _tableNameOfNetworkInfoTable, timestamp];
    
    //执行sql语句
    [_dbQueue inDatabase:^(BYStatDatabase * _Nonnull db) {
        if ([db executeUpdate:sqlDelete]) {
            BYStatLog(@"deleteRecordOfSomeDaysAgoFromNetworkInfoTable success");
        }
    }];
}

@end






