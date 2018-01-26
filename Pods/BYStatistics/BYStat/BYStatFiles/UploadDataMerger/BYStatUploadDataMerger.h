//
//  BYUploadDataMerger.h
//  BYStat
//
//  Created by 许龙 on 2017/11/28.
//  Copyright © 2017年 QDHL. All rights reserved.
//

//**************************************************************
//************************ 数据工具类 ****************************
//**************************************************************



#import <Foundation/Foundation.h>
#import "BYStatCommonDefine.h"

@interface BYStatUploadDataMerger : NSObject

/**
 各个表，长key对应短key，是一个二维字典
 一层 key：表名; value: 具体的表长key和短key字典
 二层 key: 字段长Key; value: 字段短Key
 */
@property (nonatomic, strong, readonly) NSDictionary *allTableKeysDic;


/**
 所有的时间长Key，因为数据库返回的时间是时间戳，需要根据key判断是不是时间戳来做进一步处理
 */
@property (nonatomic, strong, readonly) NSArray *allTimeKeysArray;

/**
 创建单例

 @return shareDataMerger
 */
+ (instancetype)shareDataMerger;


/**
 根据是否是调试模式打印一些需要调试的信息
 */
+ (void)byLogInfoWith:(id)messageInfo;


/**
 获取设备的基本信息字典

 @return 基本信息字典
 */
- (NSDictionary *)getDeviceBasicInfo;


/**
 把原始数据转换为上传服务器需要的格式：1.长Key变短Key；2.Date变时间戳；3.字典转jsonString;
 
 @param allTableDic 所有表的数据
 @return 目标数据
 */
- (NSDictionary *)convertDataToUploadDataWith:(NSDictionary *)allTableDic;


/**
 转换字典成jsonString

 @param dic 需要转换的字典
 @return jsonString
 */
- (NSString *)convertOriginJSONStringWith:(NSDictionary *)dic;


/**
 判断AdditionalInfoDictionary中Value是否是BYST标准类型

 @param dic 判断的AdditionalInfo字典
 @return YES:符合BYST标准类型； NO:不符合
 */
- (BOOL)judgeDicValueIsStandardTypeWith:(NSDictionary *)dic;

/**
 忽略掉额外信息里不是BYST统计标准的Value

 @param dic 额外信息字典
 @return BYST标准字典
 */
- (NSDictionary *)ignoreNotBYAdditionStandardTypeWith:(NSDictionary *)dic;


/**
 根据InfoTableType，获取打印信息的表明

 @param tableType InfoTableType
 @return 打印信息的表具体的名字
 */
- (NSString *)getLogTableNameWith:(BYStatInfoTableType )tableType;

@end
