//
//  BYUUID.h
//  BYStat
//
//  Created by 许龙 on 2017/11/29.
//  Copyright © 2017年 QDHL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *const BYUUIDsOfUserDevicesDidChangeNotification;

@interface BYStatUUID : NSObject
{
    NSMutableDictionary *_uuidForKey;
    NSString *_uuidForSession;
    NSString *_uuidForInstallation;
    NSString *_uuidForVendor;
    NSString *_uuidForDevice;
    NSString *_uuidsOfUserDevices;
    BOOL _uuidsOfUserDevices_iCloudAvailable;
}

+(NSString *)uuid;
+(NSString *)uuidForKey:(id<NSCopying>)key;
+(NSString *)uuidForSession;
+(NSString *)uuidForInstallation;
+(NSString *)uuidForVendor;
+(NSString *)uuidForDevice;
+(NSString *)uuidForDeviceMigratingValue:(NSString *)value commitMigration:(BOOL)commitMigration;
+(NSString *)uuidForDeviceMigratingValueForKey:(NSString *)key commitMigration:(BOOL)commitMigration;
+(NSString *)uuidForDeviceMigratingValueForKey:(NSString *)key service:(NSString *)service commitMigration:(BOOL)commitMigration;
+(NSString *)uuidForDeviceMigratingValueForKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup commitMigration:(BOOL)commitMigration;
+(NSArray *)uuidsOfUserDevices;
+(NSArray *)uuidsOfUserDevicesExcludingCurrentDevice;

+(BOOL)uuidValueIsValid:(NSString *)uuidValue;



@end
