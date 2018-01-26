//
//  BYStatThreadForSqliteHandle.m
//  BYStat
//
//  Created by QDHL on 2017/11/28.
//  Copyright © 2017年 QDHL. All rights reserved.
//

#import "BYStatThreadForSqliteHandle.h"

@interface BYStatThreadForSqliteHandle ()

@end

@implementation BYStatThreadForSqliteHandle

/**
 @return 数据库处理线程
 */
+(instancetype)sharedThreadForSqliteHandle{
    static dispatch_once_t onceToken;
    static BYStatThreadForSqliteHandle *threadForSqliteHandle;
    
    dispatch_once(&onceToken, ^{
        threadForSqliteHandle = [[BYStatThreadForSqliteHandle alloc]init];
        [threadForSqliteHandle start];
    });
    return threadForSqliteHandle;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        self.name = @"BYStatThreadForSqliteHandle";
    }
    return self;
}

-(void)main{
    
    [[NSRunLoop currentRunLoop] addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop]run];
}


@end
