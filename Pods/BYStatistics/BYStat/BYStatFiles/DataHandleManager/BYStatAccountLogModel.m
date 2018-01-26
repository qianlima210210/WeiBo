//
//  BYAccountLogModel.m
//  BYStat
//
//  Created by 许龙 on 2017/12/13.
//  Copyright © 2017年 QDHL. All rights reserved.
//

#import "BYStatAccountLogModel.h"
#import "BYStatCommonDefine.h"

@implementation BYStatAccountLogModel

- (instancetype)initWithUserId:(NSString *)userId provider:(NSString *)provider signInDate:(NSDate *)signInDate signOffDate:(NSDate *)signOffDate additionalInfo:(NSDictionary *)additionalInfo {
    if (self = [super init]) {
        self.userId = userId;
        self.provider = provider;
        self.signInDate = signInDate;
        self.signOffDate = signOffDate;
        if (additionalInfo) {
            [self.additionalInfo addEntriesFromDictionary:additionalInfo];
        }
    }
    return self;
}

- (instancetype)initDBLastRecordWithDic:(NSDictionary *)accountDic {
    if (self = [self init]) {
        self.userId = [accountDic objectForKey:kBYSTUserIdKey];
        self.provider = [accountDic objectForKey:kBYSTProviderKey];
        self.signInDate = [NSDate dateWithTimeIntervalSince1970:[[accountDic objectForKey:kBYSTSignInTimeKey] doubleValue]];
        self.signOffDate = [NSDate dateWithTimeIntervalSince1970:[[accountDic objectForKey:kBYSTSignOffTimeKey] doubleValue]];
        if ([[accountDic objectForKey:kBYSTAdditionalInfoKey] isKindOfClass:[NSDictionary class]]) {
            [self.additionalInfo addEntriesFromDictionary:[accountDic objectForKey:kBYSTAdditionalInfoKey]];
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

