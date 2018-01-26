//
//  BYApplicationLogModel.m
//  BYStat
//
//  Created by 许龙 on 2017/12/15.
//  Copyright © 2017年 QDHL. All rights reserved.
//

#import "BYStatApplicationLogModel.h"

@implementation BYStatApplicationLogModel

- (instancetype)initWithOpenDate:(NSDate *)openDate closeDate:(NSDate *)closeDate additionDic:(NSDictionary *)additionalDic {
    if (self = [super init]) {
        self.openDate = openDate;
        self.closeDate = closeDate;
        if (additionalDic) {
            [self.additionalDictionary addEntriesFromDictionary:additionalDic];
        }
    }
    return self;
}

- (NSMutableDictionary *)additionalDictionary {
    if (!_additionalDictionary) {
        _additionalDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _additionalDictionary;
}

@end
