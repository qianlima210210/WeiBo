//
//  BYUploadDataMerger.m
//  BYStat
//
//  Created by 许龙 on 2017/11/28.
//  Copyright © 2017年 QDHL. All rights reserved.
//

#import "BYStatUploadDataMerger.h"
#import <UIKit/UIKit.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <sys/utsname.h>
#import "BYStatUUID.h"
#import "BYStatDataHandleManager.h"
#import "NSMutableDictionary+BYStatSetObject.h"

@implementation BYStatUploadDataMerger


- (NSDictionary *)allTableKeysDic {
    return @{
             kBYSTStatUploadBasicInfoTableKey : @{
                     kBYSTApplicationChannelKey: kBYSTApplicationChannelKey_short,
                     kBYSTApplicationKeyKey: kBYSTApplicationKeyKey_short,
                     kBYSTApplicationNameKey: kBYSTApplicationNameKey_short,
                     kBYSTApplicationPackageNameKey: kBYSTApplicationPackageNameKey_short,
                     kBYSTApplicationUserIdKey: kBYSTApplicationUserIdKey_short,
                     kBYSTApplicationVersionKey: kBYSTApplicationVersionKey_short,
                     kBYSTDeviceBrandKey: kBYSTDeviceBrandKey_short,
                     kBYSTDeviceIdKey: kBYSTDeviceIdKey_short,
                     kBYSTDeviceModelKey: kBYSTDeviceModelKey_short,
                     kBYSTMACKey: kBYSTMACKey_short,
                     kBYSTMobileOperatorKey: kBYSTMobileOperatorKey_short,
                     kBYSTSDKVersionKey: kBYSTSDKVersionKey_short,
                     kBYSTSystemNameKey: kBYSTSystemNameKey_short,
                     kBYSTSystemVersionKey: kBYSTSystemVersionKey_short,
                     },
             kBYSTStatUploadApplicationInfoTableKey : @{
                     kBYSTApplicationOpenTimeKey: kBYSTApplicationOpenTimeKey_short,
                     kBYSTApplicationCloseTimeKey: kBYSTApplicationCloseTimeKey_short,
                     kBYSTAdditionalInfoKey: kBYSTAdditionalInfoKey_short,
                     },
             kBYSTStatUploadAccountInfoTableKey: @{
                     kBYSTUserIdKey: kBYSTUserIdKey_short,
                     kBYSTProviderKey: kBYSTProviderKey_short,
                     kBYSTSignInTimeKey: kBYSTSignInTimeKey_short,
                     kBYSTSignOffTimeKey: kBYSTSignOffTimeKey_short,
                     kBYSTAdditionalInfoKey: kBYSTAdditionalInfoKey_short,
                     },
             kBYSTStatUploadPageInfoTableKey: @{
                     kBYSTPageIdKey: kBYSTPageIdKey_short,
                     kBYSTPageOpenTimeKey: kBYSTPageOpenTimeKey_short,
                     kBYSTPageCloseTimeKey: kBYSTPageCloseTimeKey_short,
                     kBYSTAdditionalInfoKey: kBYSTAdditionalInfoKey_short,
                     },
             kBYSTStatUploadEventInfoTableKey: @{
                     kBYSTEventIdKey: kBYSTEventIdKey_short,
                     kBYSTEventHappenTimeKey: kBYSTEventHappenTimeKey_short,
                     kBYSTAdditionalInfoKey: kBYSTAdditionalInfoKey_short,
                     },
             kBYSTStatUploadPositionInfoTableKey: @{
                     kBYSTLongitudeKey: kBYSTLongitudeKey_short,
                     kBYSTLatitudeKey: kBYSTLatitudeKey_short,
                     kBYSTPositionChangeTimeKey: kBYSTPositionChangeTimeKey_short,
                     kBYSTAdditionalInfoKey: kBYSTAdditionalInfoKey_short,
                     },
             kBYSTStatUploadNetworkInfoTableKey: @{
                     kBYSTNetworkTypeKey: kBYSTNetworkTypeKey_short,
                     kBYSTNetworkChangeTimeKey: kBYSTNetworkChangeTimeKey_short,
                     kBYSTAdditionalInfoKey: kBYSTAdditionalInfoKey_short,
                     },
             };
}

- (NSArray *)allTimeKeysArray {
    return @[kBYSTApplicationOpenTimeKey, kBYSTApplicationCloseTimeKey, kBYSTSignInTimeKey, kBYSTSignOffTimeKey, kBYSTPageOpenTimeKey, kBYSTPageCloseTimeKey, kBYSTEventHappenTimeKey, kBYSTPositionChangeTimeKey, kBYSTNetworkChangeTimeKey];
}

#pragma mark - Open Methods

+ (instancetype)shareDataMerger {
    static BYStatUploadDataMerger *dataMerger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataMerger = [[BYStatUploadDataMerger alloc] init];
    });
    return dataMerger;
}

+ (void)byLogInfoWith:(id)messageInfo {
#ifdef DEBUG
    if ([BYStatDataHandleManager shareDataHandleManager].isByStatDebug) {
        NSLog(@"%@",messageInfo);
    }
#endif
}

#pragma mark 获取基本信息表字典信息
- (NSDictionary *)getDeviceBasicInfo {
    NSMutableDictionary *configDic = [[NSMutableDictionary alloc] initWithCapacity:11];
    UIDevice *currentDevice = [UIDevice currentDevice];
    
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    //应用名
    NSString *applicationName = [infoDic objectForKey:@"CFBundleDisplayName"] ? [infoDic objectForKey:@"CFBundleDisplayName"] : [infoDic objectForKey:@"CFBundleName"];
    [configDic byStat_setObject:applicationName forKey:kBYSTApplicationNameKey];
    //应用BUNDLEID
    NSString *applicationPackageName = [infoDic objectForKey:@"CFBundleIdentifier"];
    [configDic byStat_setObject:applicationPackageName forKey:kBYSTApplicationPackageNameKey];
    //应用版本号
    NSString *applicationVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
    [configDic byStat_setObject:applicationVersion forKey:kBYSTApplicationVersionKey];
    //设备品牌
    NSString *deviceBrand =@"apple";
    [configDic byStat_setObject:deviceBrand forKey:kBYSTDeviceBrandKey];
    //设备唯一标识
    NSString *deviceId = [BYStatUUID uuidForDevice];
    [configDic byStat_setObject:deviceId forKey:kBYSTDeviceIdKey];
    //设备型号 iphone9,2
    NSString *deviceModel = [self getDeviceName];
    [configDic byStat_setObject:deviceModel forKey:kBYSTDeviceModelKey];
    //网卡标记 iOS默认空值
    NSString *mac = @"";
    [configDic byStat_setObject:mac forKey:kBYSTMACKey];
    //运营商
    NSString *mobileOperator = [self getCarrierName];
    [configDic byStat_setObject:mobileOperator forKey:kBYSTMobileOperatorKey];
    //SDK版本号
    NSString *sdkVersion = BYSDKVersion;
    [configDic byStat_setObject:sdkVersion forKey:kBYSTSDKVersionKey];
    //系统名称
    NSString *systemName = currentDevice.systemName;
    [configDic byStat_setObject:systemName forKey:kBYSTSystemNameKey];
    //系统版本
    NSString *systemVersion = currentDevice.systemVersion;
    [configDic byStat_setObject:systemVersion forKey:kBYSTSystemVersionKey];
    
    return configDic;
}


#pragma mark 把原始数据转换为上传服务器需要的格式
- (NSDictionary *)convertDataToUploadDataWith:(NSDictionary *)allTableDic {
    NSMutableDictionary *allShortInfoTableDic = [NSMutableDictionary dictionaryWithCapacity:allTableDic.count];
    
    for (NSString *tableNameKey in allTableDic.allKeys) {
        NSDictionary *shortKeyDic = [self.allTableKeysDic objectForKey:tableNameKey];
        if ([tableNameKey isEqualToString:kBYSTStatUploadBasicInfoTableKey] && [[allTableDic objectForKey:tableNameKey] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *originDic = [allTableDic objectForKey:tableNameKey];
            NSDictionary *shortInfoDic = [self getUploadInfoDicWith:originDic shortKeyDic:shortKeyDic];
            [allShortInfoTableDic byStat_setObject:shortInfoDic forKey:tableNameKey];
        }else if ([[allTableDic objectForKey:tableNameKey] isKindOfClass:[NSArray class]]) {
            NSArray *tableInfoArray = [allTableDic objectForKey:tableNameKey];
            NSMutableArray *tempTableInfoArray = [NSMutableArray arrayWithCapacity:tableInfoArray.count];
            for (NSDictionary *originDic in tableInfoArray) {
                NSDictionary *shortInfoDic = [self getUploadInfoDicWith:originDic shortKeyDic:shortKeyDic];
                [tempTableInfoArray addObject:shortInfoDic];
            }
            [allShortInfoTableDic byStat_setObject:tempTableInfoArray forKey:tableNameKey];
        }
    }
    return allShortInfoTableDic;
}

#pragma mark 把字典转成jsonString
- (NSString *)convertOriginJSONStringWith:(NSDictionary *)dic {
    if (![dic isKindOfClass:[NSDictionary class]]) {
        BYStatWarnLog(@"字典转jsonString,%@不是字典类型",dic);
        return @"{}";
    }
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:0
                                                         error:&error];
    
    if (jsonData == nil || error != nil) {
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}


#pragma mark 判断字典类型是不是BYST要求的类型， 现在要求key-Value必须是String类型
- (BOOL)judgeDicValueIsStandardTypeWith:(NSDictionary *)dic {
    for (id value in dic.allValues) {
        if (![value isKindOfClass:[NSString class]]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark 忽略掉额外信息里不是BYST统计标准的Value
- (NSDictionary *)ignoreNotBYAdditionStandardTypeWith:(NSDictionary *)dic {
    if (dic == nil) {
        return nil;
    }
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    for (NSString *key in tempDic.allKeys) {
        id value = [tempDic objectForKey:key];
        if (![value isKindOfClass:[NSString class]]) {
            [tempDic removeObjectForKey:key];
        }
    }
    return tempDic;
}

#pragma mark 根据InfoTableType，获取打印信息的表明
- (NSString *)getLogTableNameWith:(BYStatInfoTableType )tableType {
    NSString *tableName = @"";
    switch (tableType) {
        case BYStatInfoTableTypeOfBaseInfo:
            tableName = @"基本信息统计";
            break;
        case BYStatInfoTableTypeOfApplicationInfo:
            tableName = @"应用信息统计";
            break;
        case BYStatInfoTableTypeOfPageInfo:
            tableName = @"页面信息统计";
            break;
        case BYStatInfoTableTypeOfAccountInfo:
            tableName = @"帐号信息统计";
            break;
        case BYStatInfoTableTypeOfEventInfo:
            tableName = @"事件信息统计";
            break;
        case BYStatInfoTableTypeOfPositionInfo:
            tableName = @"位置信息统计";
            break;
        case BYStatInfoTableTypeOfNetworkInfo:
            tableName = @"网络信息统计";
            break;

        default:
            break;
    }
    return tableName;
}

/*
 //Simultor
 @"i386"      on 32-bit Simulator
 @"x86_64"    on 64-bit Simulator
 
 //iPhone
 @"iPhone1,1" on iPhone
 @"iPhone1,2" on iPhone 3G
 @"iPhone2,1" on iPhone 3GS
 @"iPhone3,1" on iPhone 4 (GSM)
 @"iPhone3,3" on iPhone 4 (CDMA/Verizon/Sprint)
 @"iPhone4,1" on iPhone 4S
 @"iPhone5,1" on iPhone 5 (model A1428, AT&T/Canada)
 @"iPhone5,2" on iPhone 5 (model A1429, everything else)
 @"iPhone5,3" on iPhone 5c (model A1456, A1532 | GSM)
 @"iPhone5,4" on iPhone 5c (model A1507, A1516, A1526 (China), A1529 | Global)
 @"iPhone6,1" on iPhone 5s (model A1433, A1533 | GSM)
 @"iPhone6,2" on iPhone 5s (model A1457, A1518, A1528 (China), A1530 | Global)
 @"iPhone7,1" on iPhone 6 Plus
 @"iPhone7,2" on iPhone 6
 @"iPhone8,1" on iPhone 6S
 @"iPhone8,2" on iPhone 6S Plus
 @"iPhone8,4" on iPhone SE
 @"iPhone9,1" on iPhone 7 (CDMA)
 @"iPhone9,3" on iPhone 7 (GSM)
 @"iPhone9,2" on iPhone 7 Plus (CDMA)
 @"iPhone9,4" on iPhone 7 Plus (GSM)
 
 //iPad 1
 @"iPad1,1" on iPad - Wifi (model A1219)
 @"iPad1,1" on iPad - Wifi + Cellular (model A1337)
 
 //iPad 2
 @"iPad2,1" - Wifi (model A1395)
 @"iPad2,2" - GSM (model A1396)
 @"iPad2,3" - 3G (model A1397)
 @"iPad2,4" - Wifi (model A1395)
 
 // iPad Mini
 @"iPad2,5" - Wifi (model A1432)
 @"iPad2,6" - Wifi + Cellular (model  A1454)
 @"iPad2,7" - Wifi + Cellular (model  A1455)
 
 //iPad 3
 @"iPad3,1" - Wifi (model A1416)
 @"iPad3,2" - Wifi + Cellular (model  A1403)
 @"iPad3,3" - Wifi + Cellular (model  A1430)
 
 //iPad 4
 @"iPad3,4" - Wifi (model A1458)
 @"iPad3,5" - Wifi + Cellular (model  A1459)
 @"iPad3,6" - Wifi + Cellular (model  A1460)
 
 //iPad AIR
 @"iPad4,1" - Wifi (model A1474)
 @"iPad4,2" - Wifi + Cellular (model A1475)
 @"iPad4,3" - Wifi + Cellular (model A1476)
 
 // iPad Mini 2
 @"iPad4,4" - Wifi (model A1489)
 @"iPad4,5" - Wifi + Cellular (model A1490)
 @"iPad4,6" - Wifi + Cellular (model A1491)
 
 // iPad Mini 3
 @"iPad4,7" - Wifi (model A1599)
 @"iPad4,8" - Wifi + Cellular (model A1600)
 @"iPad4,9" - Wifi + Cellular (model A1601)
 
 // iPad Mini 4
 @"iPad5,1" - Wifi (model A1538)
 @"iPad5,2" - Wifi + Cellular (model A1550)
 
 //iPad AIR 2
 @"iPad5,3" - Wifi (model A1566)
 @"iPad5,4" - Wifi + Cellular (model A1567)
 
 // iPad PRO 12.9"
 @"iPad6,3" - Wifi (model A1673)
 @"iPad6,4" - Wifi + Cellular (model A1674)
 @"iPad6,4" - Wifi + Cellular (model A1675)
 
 //iPad PRO 9.7"
 @"iPad6,7" - Wifi (model A1584)
 @"iPad6,8" - Wifi + Cellular (model A1652)
 
 //iPod Touch
 @"iPod1,1"   on iPod Touch
 @"iPod2,1"   on iPod Touch Second Generation
 @"iPod3,1"   on iPod Touch Third Generation
 @"iPod4,1"   on iPod Touch Fourth Generation
 @"iPod7,1"   on iPod Touch 6th Generation
 
 */

#pragma mark - Private Methods

#pragma mark 获取设备型号
- (NSString *)getDeviceName {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];

    return deviceModel;
}

#pragma mark 获取本机运营商名称
- (NSString *)getCarrierName {
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [info subscriberCellularProvider];
    //当前手机所属运营商名称，eg:中国联通
    NSString *mobile;
    //先判断有没有SIM卡，如果没有则不获取本机运营商
    if (!carrier.isoCountryCode) {
        mobile = @"无运营商";
    }else{
        mobile = [carrier carrierName];
    }
    return mobile;
}

#pragma mark 实际的转换代码，做了3种事情，1.长Key变短Key；2.Date变时间戳；3.Data转字典;
- (NSDictionary *)getUploadInfoDicWith:(NSDictionary *)originDic shortKeyDic:(NSDictionary *)shortKeyDic{
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithCapacity:originDic.count];
    for (NSString *infoKey in originDic.allKeys) {
        if (![shortKeyDic.allKeys containsObject:infoKey]) {
            continue;
        }
        NSString *shortKey = [shortKeyDic objectForKey:infoKey];
        if ([[originDic objectForKey:infoKey] isKindOfClass:[NSDate class]]) {
            NSTimeInterval timestamp = [(NSDate *)[originDic objectForKey:infoKey] timeIntervalSince1970] * 1000;
            long long integralTime = timestamp;
            [tempDic byStat_setObject:@(integralTime) forKey:shortKey];
        }else if ([self.allTimeKeysArray containsObject:infoKey]) {
            double timestamp = [[originDic objectForKey:infoKey] doubleValue] * 1000;
            long long integralTime = timestamp;
            [tempDic byStat_setObject:@(integralTime) forKey:shortKey];
        }else if ([infoKey isEqualToString:kBYSTAdditionalInfoKey]) {
            NSData *additionalData = [originDic objectForKey:infoKey];
            if ([additionalData isKindOfClass:[NSData class]]) {
                NSDictionary *additionDic = [NSJSONSerialization JSONObjectWithData:additionalData options:NSJSONReadingMutableLeaves error:nil];
                [tempDic byStat_setObject:additionDic ? additionDic : @{} forKey:shortKey];
            }else {
                [tempDic byStat_setObject:@{} forKey:shortKey];
            }
        }else {
            [tempDic byStat_setObject:[originDic objectForKey:infoKey] forKey:shortKey];
        }
    }
    return tempDic;
}




@end
