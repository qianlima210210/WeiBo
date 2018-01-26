//
//  BYDataHandleManager.h
//  BYStat
//
//  Created by 许龙 on 2017/11/28.
//  Copyright © 2017年 QDHL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BYStatSqliteHandleCoordinator.h"

@interface BYStatDataHandleManager : NSObject

+ (instancetype)shareDataHandleManager;

/**
 是否是调试模式
 */
@property (nonatomic, assign, getter=isByStatDebug) BOOL byStatDebug;

#pragma mark - 配置基本信息
/**********************************配置基本信息****************************/
/**
 转换初始化BYHL统计信息
 
 @param applicationKey 应用Key，作为区分其它应用的唯一标记
 @param applicationChannel 应用发布渠道，appstore | enterprise
 */
- (void)handleConfigureBasicInfoWithApplicationName:(NSString *)applicationKey
                                 applicationChannel:(NSString *)applicationChannel;

#pragma mark - 应用统计
/**********************************应用统计****************************/

/**
 打开应用 可附带额外的信息
 
 @param additionalInfo 额外的信息
 */
- (void)handleOpenApplicationWithAdditionalInfo:(NSDictionary *)additionalInfo;

/**
 关闭应用 可附带额外的信息 此方法暂时关闭外界不需要调用
 
 @param additionalInfo 额外的信息
 */
//- (void)handleCloseApplicationWithAdditionalInfo:(NSDictionary *)additionalInfo;


#pragma mark - 页面统计
/**********************************页面统计****************************/

/**
 转换开始页面统计 附带额外信息
 
 @param pageID 页面ID
 @param additionalInfo 额外的信息
 */
- (void)handleBeginLogPageView:(NSString *)pageID additionalInfo:(NSDictionary *)additionalInfo;

/**
 转换结束页面统计 可附带额外信息
 
 @param pageID 页面ID
 @param additionalInfo 额外的信息
 */
- (void)handleEndLogPageView:(NSString *)pageID additionalInfo:(NSDictionary *)additionalInfo;

#pragma mark - 帐号统计
/**********************************帐号统计****************************/
/**
 转换帐号登录统计
 
 @param userId 用户ID
 @param additionalInfo 额外的信息
 */
- (void)handleSignInWithUserId:(NSString *)userId provider:(NSString *)provider additionalInfo:(NSDictionary *)additionalInfo;


/**
 转换帐号登出统计
 
 @param additionalInfo 额外的信息
 */
- (void)handleSignOffWithAdditionalInfo:(NSDictionary *)additionalInfo;


#pragma mark - 事件统计
/**********************************事件统计****************************/

/**
 转换事件统计 可附带额外信息
 
 @param eventId 事件ID
 @param additionalInfo 额外的信息
 */
- (void)handleEvent:(NSString *)eventId additionalInfo:(NSDictionary *)additionalInfo;

#pragma mark - 位置统计
/**********************************位置统计****************************/
/**
 转换经纬度信息 可附带额外的信息
 
 @param latitude 纬度
 @param longitude 经度
 @param additionalInfo 额外的信息
 */
- (void)handlePositionLatitude:(double)latitude longitude:(double)longitude additionalInfo:(NSDictionary *)additionalInfo;


#pragma mark - 网络统计
/**********************************网络统计****************************/

/**
 转换网络统计信息 可附带额外的信息
 
 @param network 网络状态
 @param additionalInfo 额外的信息
 */
- (void)handleNetWork:(NSString *)network additionalInfo:(NSDictionary *)additionalInfo;


#pragma mark - 上传数据
/**********************************上传数据****************************/

/**
 上传数据
 */
- (void)handleUploadStatData;


#pragma mark - 关闭监听：网络监听和应用打开和关闭的监听
/**
 关闭监听，包括应用打开和关闭的监听、网络状态变化的监听
 */
- (void)closeListenApplicationAndNetwork;


@end

#pragma mark - 分类：把数据写入数据库
/**********************************把数据写入数据库的分类****************************/
@interface BYStatDataHandleManager (InsertData)

/**
 写数据
 
 @param tableType 表名类型
 @param dataDic 数据字典
 */
- (void)insertDataToTable:(BYStatInfoTableType )tableType data:(NSDictionary *)dataDic;

@end

#pragma mark - 分类：更新数据库中的数据
/**********************************更新数据库中的数据的分类****************************/
@interface BYStatDataHandleManager (UpdateData)

/**
 更新数据
 
 @param tableType 表名类型
 @param dataDic 数据字典
 */
- (void)updateDataToTable:(BYStatInfoTableType )tableType data:(NSDictionary *)dataDic;

@end

#pragma mark - 分类：从数据库获取数据
/**********************************从数据库获取数据的分类****************************/
@interface BYStatDataHandleManager (GetData)

/**
 获取本地数据库表中数据
 
 @param tableType 表名类型
 @param successBlock 获取之后调用的block
 */
- (void)getDataWith:(BYStatInfoTableType)tableType successBlock:(sqliteHandleCallback )successBlock;


/**
 获取数据库中最后一条帐号信息

 @param successBlock 获取之后调用的block
 */
- (void)getLastAccountInfoDataWithSuccessBlock:(sqliteHandleCallback )successBlock;

@end

#pragma mark - 分类：从数据库删除数据
/**********************************从数据库删除数据的分类****************************/
@interface BYStatDataHandleManager (DeleteData)

/**
 删除指定多少天之前的数据（以当前时间为根据）

 @param beforeDay 指定天数
 */
- (void)deleteAllTableDataBeforeDays:(NSInteger )beforeDay;

/**
 从数据库中删除指定的数据
 
 @param dataArray 指定的数据
 @param tableType 表名类型
 */
- (void)deleteData:(NSArray *)dataArray tableType:(BYStatInfoTableType)tableType;


@end

