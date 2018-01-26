//
//  BYPageLogModel.h
//  BYStat
//
//  Created by 许龙 on 2017/12/7.
//  Copyright © 2017年 QDHL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BYStatPageLogModel : NSObject

/**
 页面ID
 */
@property (nonatomic, strong) NSString *pageId;

/**
 页面打开时间
 */
@property (nonatomic, strong) NSDate *openTime;

/**
 页面关闭时间
 */
@property (nonatomic, strong) NSDate *closeTime;

/**
 额外的信息 在结束页面的时候，设置的时候，用addEntriesFromDictionary方法
 */
@property (nonatomic, strong) NSMutableDictionary *additionalInfo;

//初始化方法
- (instancetype)initWithPageId:(NSString *)pageId
                      openTiem:(NSDate *)openTime
                     closeTime:(NSDate *)closeTime
                additionalInfo:(NSDictionary *)additionalInfo;


@end



