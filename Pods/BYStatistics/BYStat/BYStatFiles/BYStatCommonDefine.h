//
//  BYUrlDefine.h
//  BYStat
//
//  Created by Robin on 2017/11/28.
//  Copyright © 2017年 QDHL. All rights reserved.
//

#ifndef BYUrlDefine_h
#define BYUrlDefine_h


#define BYSDKVersion @"1.0.0" // 版本号按3位走
#define kBYSTApplicationChannelDefaultValue @"App Store"

//有效的统计数据周期（天）， 删除这个周期之前的数据
#define kValidRecordDuration 9


//MARK:信息表类型常量
typedef enum : unsigned long {
    BYStatInfoTableTypeOfBaseInfo,            //代表基本信息表
    BYStatInfoTableTypeOfApplicationInfo,     //代表应用信息表
    BYStatInfoTableTypeOfAccountInfo,         //代表账号信息表
    BYStatInfoTableTypeOfPageInfo,            //代表页面信息表
    BYStatInfoTableTypeOfEventInfo,           //代表事件信息表
    BYStatInfoTableTypeOfPositionInfo,        //代表位置信息表
    BYStatInfoTableTypeOfNetworkInfo,         //代表网络信息表
} BYStatInfoTableType;

/*********************************************
以下7个信息表如果增加了字段,相应的在BYUploadDataMerger中allTableKeysDic字典中也对应增加
 如果增加的字段不需要上传给服务器，则不需要在allTableKeysDic字典中增加（eg: kBYSTIDKey）
 *********************************************/

//************************** 基本信息表对应的Key **************************
#define kBYSTIDKey         @"ID"

#define kBYSTApplicationChannelKey         @"ApplicationChannel"
#define kBYSTApplicationChannelKey_short   @"AC"

#define kBYSTApplicationKeyKey             @"ApplicationKey"
#define kBYSTApplicationKeyKey_short       @"AK"

#define kBYSTApplicationNameKey            @"ApplicationName"
#define kBYSTApplicationNameKey_short      @"AN"

#define kBYSTApplicationPackageNameKey         @"ApplicationPackageName"
#define kBYSTApplicationPackageNameKey_short   @"APN"

#define kBYSTApplicationUserIdKey          @"ApplicationUserId"
#define kBYSTApplicationUserIdKey_short    @"AUI"

#define kBYSTApplicationVersionKey         @"ApplicationVersion"
#define kBYSTApplicationVersionKey_short   @"AV"

#define kBYSTDeviceBrandKey                @"DeviceBrand"
#define kBYSTDeviceBrandKey_short          @"DB"

#define kBYSTDeviceIdKey                   @"DeviceId"
#define kBYSTDeviceIdKey_short             @"DI"

#define kBYSTDeviceModelKey                @"DeviceModel"
#define kBYSTDeviceModelKey_short          @"DM"

#define kBYSTMACKey                        @"MAC"
#define kBYSTMACKey_short                  @"MAC"

#define kBYSTMobileOperatorKey             @"MobileOperator"
#define kBYSTMobileOperatorKey_short       @"MO"

#define kBYSTSDKVersionKey                 @"SDKVersion"
#define kBYSTSDKVersionKey_short           @"SDKV"

#define kBYSTSystemNameKey                 @"SystemName"
#define kBYSTSystemNameKey_short           @"SN"

#define kBYSTSystemVersionKey              @"SystemVersion"
#define kBYSTSystemVersionKey_short        @"SV"

//************************** 应用信息表对应的Key **************************
#define kBYSTApplicationOpenTimeKey           @"ApplicationOpenTime"
#define kBYSTApplicationOpenTimeKey_short     @"AOT"

#define kBYSTApplicationCloseTimeKey          @"ApplicationCloseTime"
#define kBYSTApplicationCloseTimeKey_short    @"ACT"

//************************** 帐号信息表对应的Key **************************
#define kBYSTUserIdKey            @"UserId"
#define kBYSTUserIdKey_short      @"UI"

#define kBYSTProviderKey          @"Provider"
#define kBYSTProviderKey_short    @"PROV"

#define kBYSTSignInTimeKey        @"SignInTime"
#define kBYSTSignInTimeKey_short  @"SIT"

#define kBYSTSignOffTimeKey       @"SignOffTime"
#define kBYSTSignOffTimeKey_short @"SOT"

//************************** 页面信息表对应的Key **************************
#define kBYSTPageIdKey                @"PageId"
#define kBYSTPageIdKey_short          @"PI"

#define kBYSTPageOpenTimeKey          @"PageOpenTime"
#define kBYSTPageOpenTimeKey_short    @"POT"

#define kBYSTPageCloseTimeKey         @"PageCloseTime"
#define kBYSTPageCloseTimeKey_short   @"PCT"

//************************** 事件信息表对应的Key **************************
#define kBYSTEventIdKey               @"EventId"
#define kBYSTEventIdKey_short         @"EI"

#define kBYSTEventHappenTimeKey       @"EventHappenTime"
#define kBYSTEventHappenTimeKey_short @"EHT"

//************************** 位置信息表对应的Key **************************
#define kBYSTLongitudeKey         @"Longitude"
#define kBYSTLongitudeKey_short   @"LON"

#define kBYSTLatitudeKey          @"Latitude"
#define kBYSTLatitudeKey_short    @"LAT"

#define kBYSTPositionChangeTimeKey        @"PositionChangeTime"
#define kBYSTPositionChangeTimeKey_short  @"PCT"

//************************** 网络信息表对应的Key **************************
#define kBYSTNetworkTypeKey               @"NetworkType"
#define kBYSTNetworkTypeKey_short         @"NT"

#define kBYSTNetworkChangeTimeKey         @"NetworkChangeTime"
#define kBYSTNetworkChangeTimeKey_short   @"NCT"


//************************* 额外信息Key ********************************
#define kBYSTAdditionalInfoKey            @"AdditionalInfo"
#define kBYSTAdditionalInfoKey_short      @"AI"


//************************* 上传服务器时各个数据对应的Key ********************************
#define kBYSTStatUploadBasicInfoTableKey         @"BaseInfo"
#define kBYSTStatUploadApplicationInfoTableKey   @"ApplicationInfo"
#define kBYSTStatUploadAccountInfoTableKey       @"AccountInfo"
#define kBYSTStatUploadPageInfoTableKey          @"PageInfo"
#define kBYSTStatUploadEventInfoTableKey         @"EventInfo"
#define kBYSTStatUploadPositionInfoTableKey      @"PositionInfo"
#define kBYSTStatUploadNetworkInfoTableKey       @"NetworkInfo"


//************************* 和数据库操作时回掉方法的Key ********************************
#define kBYSTSqliteHandleCallback   @"BYSTSqliteHandleCallback"


#define BYStatWarnLogInFo(format, ...) NSLog((@"\n*****************BYStat Warning********************\n" format), ##__VA_ARGS__)


//警告无关乎调试模式
#ifdef DEBUG
#define BYStatWarnLog(format, ...) BYStatWarnLogInFo(format, ##__VA_ARGS__)
#define BYStatLog(message) [BYStatUploadDataMerger byLogInfoWith:message]
#else
#define BYStatWarnLog(format, ...)
#define BYStatLog(format, ...)
#endif



#endif /* BYUrlDefine_h */
