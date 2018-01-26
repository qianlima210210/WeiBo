//
//  BYStatThreadForSqliteHandle.h
//  BYStat
//
//  Created by QDHL on 2017/11/28.
//  Copyright © 2017年 QDHL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BYStatThreadForSqliteHandle : NSThread

/**
 @return 数据库处理线程
 */
+(instancetype)sharedThreadForSqliteHandle;


@end
