//
//  BYAccountLogModel.h
//  BYStat
//
//  Created by 许龙 on 2017/12/13.
//  Copyright © 2017年 QDHL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BYStatAccountLogModel : NSObject

/**
 用户ID
 */
@property (nonatomic, strong) NSString *userId;

/**
 提供者（weixin或者其它第三方）
 */
@property (nonatomic, strong) NSString *provider;

/**
 登录时间
 */
@property (nonatomic, strong) NSDate *signInDate;

/**
 登出时间
 */
@property (nonatomic, strong) NSDate *signOffDate;

/**
 额外信息
 */
@property (nonatomic, strong) NSMutableDictionary *additionalInfo;

//初始化方法
- (instancetype)initWithUserId:(NSString *)userId
                      provider:(NSString *)provider
                    signInDate:(NSDate *)signInDate
                   signOffDate:(NSDate *)signOffDate
                additionalInfo:(NSDictionary *)additionalInfo;


/**
 根据**数据库**返回的最后一条记录 初始化AccountLogModel方法

 @param accountDic 数据库返回的字典 时间是时间戳， 额外信息是NSData
 @return self
 */
- (instancetype)initDBLastRecordWithDic:(NSDictionary *)accountDic;

@end

