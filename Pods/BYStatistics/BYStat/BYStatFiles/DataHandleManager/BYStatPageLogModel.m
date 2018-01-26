//
//  BYPageLogModel.m
//  BYStat
//
//  Created by 许龙 on 2017/12/7.
//  Copyright © 2017年 QDHL. All rights reserved.
//

#import "BYStatPageLogModel.h"

@implementation BYStatPageLogModel


- (instancetype)initWithPageId:(NSString *)pageId openTiem:(NSDate *)openTime closeTime:(NSDate *)closeTime additionalInfo:(NSDictionary *)additionalInfo {
    if (self = [super init]) {
        self.pageId = pageId;
        self.openTime = openTime;
        self.closeTime = closeTime;
        if (additionalInfo) {
            [self.additionalInfo addEntriesFromDictionary:additionalInfo];
        }
    }
    return self;
}


- (NSMutableDictionary *)additionalInfo {
    if (!_additionalInfo) {
        _additionalInfo = [[NSMutableDictionary alloc] init];
    }
    return _additionalInfo;
}

@end


