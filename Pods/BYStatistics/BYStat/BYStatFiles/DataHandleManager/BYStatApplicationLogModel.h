//
//  BYApplicationLogModel.h
//  BYStat
//
//  Created by 许龙 on 2017/12/15.
//  Copyright © 2017年 QDHL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BYStatApplicationLogModel : NSObject

@property (nonatomic, strong) NSDate *openDate;

@property (nonatomic, strong) NSDate *closeDate;

@property (nonatomic, strong) NSMutableDictionary *additionalDictionary;

- (instancetype)initWithOpenDate:(NSDate *)openDate
                       closeDate:(NSDate *)closeDate
                     additionDic:(NSDictionary *)additionalDic;

@end
