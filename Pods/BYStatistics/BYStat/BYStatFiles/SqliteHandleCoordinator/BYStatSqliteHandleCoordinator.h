//
//  BYStatSqliteHandleCoordinator.h
//  BYStat
//
//  Created by QDHL on 2017/11/28.
//  Copyright © 2017年 QDHL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BYStatCommonDefine.h"

//MARK:数据库操作回调
typedef void(^sqliteHandleCallback)(BYStatInfoTableType type, id result);


//操作协调层：数据库、表的创建；数据库的兼容
@interface BYStatSqliteHandleCoordinator : NSObject

/**
 获取数据库操作协调器单例
 @return 数据库操作协调器单例
 */
+(instancetype)sharedSqliteHandleCoordinator;

/**
 删除库中某天前的记录
 */
-(void)deleteRecordOfSomeDaysAgo:(NSNumber*)someDays;

@end

//基本信息表操作协调层：针对该表的操作
@interface BYStatSqliteHandleCoordinator (BaseInfoTable)

/**
 查询基本信息表
 @param param 包含操作回调
 */
-(void)queryRecordFromBaseInfoTableWithParam:(NSDictionary*)param;

/**
 插入记录到基本信息表
 @param param 参数信息
 */
-(void)insertRecordToBaseInfoTableWithParam:(NSDictionary*)param;

@end

//应用信息表操作协调层：针对该表的操作
@interface BYStatSqliteHandleCoordinator (ApplicationInfoTable)

/**
 插入记录到应用信息表
 @param param 参数信息
 */
-(void)insertRecordToApplicationInfoTableWithParam:(NSDictionary*)param;

/**
 更新记录到应用信息表
 @param param 参数信息
 */
-(void)updateRecordToApplicationInfoTableWithParam:(NSDictionary*)param;

/**
 查询应用信息表
 @param param 包含操作回调
 */
-(void)queryRecordFromApplicationInfoTableWithParam:(NSDictionary*)param;

/**
 删除应用信息表中的记录
 @param param 参数信息
 */
-(void)deleteRecordFromApplicationInfoTableWithParam:(NSArray*)param;

/**
 删除应用信息表中某天前的记录
 @param timestamp 某天前的时间戳
 */
-(void)deleteRecordOfSomeDaysAgoFromApplicationInfoTable:(NSTimeInterval)timestamp;


@end

//页面信息表操作协调层：针对该表的操作
@interface BYStatSqliteHandleCoordinator (PageInfoTable)

/**
 插入记录到页面信息表
 @param param 参数信息
 */
-(void)insertRecordToPageInfoTableWithParam:(NSDictionary*)param;

/**
 更新记录到页面信息表
 @param param 参数信息
 */
-(void)updateRecordToPageInfoTableWithParam:(NSDictionary*)param;

/**
 查询页面信息表
 @param param 包含操作回调
 */
-(void)queryRecordFromPageInfoTableWithParam:(NSDictionary*)param;

/**
 删除页面信息表中的记录
 @param param 参数信息
 */
-(void)deleteRecordFromPageInfoTableWithParam:(NSArray*)param;

/**
 删除页面信息表中某天前的记录
 @param timestamp 某天前的时间戳
 */
-(void)deleteRecordOfSomeDaysAgoFromPageInfoTable:(NSTimeInterval)timestamp;

@end


//事件信息表操作协调层：针对该表的操作
@interface BYStatSqliteHandleCoordinator (EventInfoTable)

/**
 插入记录到事件信息表
 @param param 参数信息
 */
-(void)insertRecordToEventInfoTableWithParam:(NSDictionary*)param;

/**
 查询事件信息表
 @param param 包含操作回调
 */
-(void)queryRecordFromEventInfoTableWithParam:(NSDictionary*)param;

/**
 删除事件信息表中的记录
 @param param 参数信息
 */
-(void)deleteRecordFromEventInfoTableWithParam:(NSArray*)param;

/**
 删除事件信息表中某天前的记录
 @param timestamp 某天前的时间戳
 */
-(void)deleteRecordOfSomeDaysAgoFromEventInfoTable:(NSTimeInterval)timestamp;

@end


//位置信息表操作协调层：针对该表的操作
@interface BYStatSqliteHandleCoordinator (PositionInfoTable)

/**
 插入记录到位置信息表
 @param param 参数信息
 */
-(void)insertRecordToPositionInfoTableWithParam:(NSDictionary*)param;

/**
 查询位置信息表
 @param param 包含操作回调
 */
-(void)queryRecordFromPositionInfoTableWithParam:(NSDictionary*)param;

/**
 删除位置信息表中的记录
 @param param 参数信息
 */
-(void)deleteRecordFromPositionInfoTableWithParam:(NSArray*)param;

/**
 删除位置信息表中某天前的记录
 @param timestamp 某天前的时间戳
 */
-(void)deleteRecordOfSomeDaysAgoFromPositionInfoTable:(NSTimeInterval)timestamp;

@end


//网络信息表操作协调层：针对该表的操作
@interface BYStatSqliteHandleCoordinator (NetworkInfoTable)

/**
 插入记录到网络信息表
 @param param 参数信息
 */
-(void)insertRecordToNetworkInfoTableWithParam:(NSDictionary*)param;

/**
 查询网络信息表
 @param param 包含操作回调
 */
-(void)queryRecordFromNetworkInfoTableWithParam:(NSDictionary*)param;

/**
 删除网络信息表中的记录
 @param param 参数信息
 */
-(void)deleteRecordFromNetworkInfoTableWithParam:(NSArray*)param;

/**
 删除网络信息表中某天前的记录
 @param timestamp 某天前的时间戳
 */
-(void)deleteRecordOfSomeDaysAgoFromNetworkInfoTable:(NSTimeInterval)timestamp;

@end

//账户信息表操作协调层：针对该表的操作
@interface BYStatSqliteHandleCoordinator (AccountInfoTable)

/**
 插入记录到账号信息表
 @param param 参数信息
 */
-(void)insertRecordToAccountInfoTableWithParam:(NSDictionary*)param;

/**
 更新记录到账号信息表
 @param param 参数信息
 */
-(void)updateRecordToAccountInfoTableWithParam:(NSDictionary*)param;

/**
 查询账号信息表
 @param param 包含操作回调
 */
-(void)queryRecordFromAccountInfoTableWithParam:(NSDictionary*)param;

/**
 查询账号信息表最后一条记录
 @param param 包含操作回调
 */
-(void)queryLastRecordFromAccountInfoTableWithParam:(NSDictionary*)param;

/**
 删除账号信息表中的记录
 @param param 参数信息
 */
-(void)deleteRecordFromAccountInfoTableWithParam:(NSArray*)param;

/**
 删除账号信息表中某天前的记录
 @param timestamp 某天前的时间戳
 */
-(void)deleteRecordOfSomeDaysAgoFromAccountInfoTable:(NSTimeInterval)timestamp;

@end



