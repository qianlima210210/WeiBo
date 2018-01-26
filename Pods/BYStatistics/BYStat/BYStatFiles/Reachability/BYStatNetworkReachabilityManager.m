//
//  BYNetworkReachabilityManager.m
//  BYStat
//
//  Created by 许龙 on 2017/11/29.
//  Copyright © 2017年 QDHL. All rights reserved.
//

#import "BYStatNetworkReachabilityManager.h"
#if !TARGET_OS_WATCH
#import <UIKit/UIKit.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

NSString * const BYNetworkingReachabilityDidChangeNotification = @"com.qdhl.networking.reachability.change";
NSString * const BYNetworkingReachabilityNotificationStatusItem = @"BYNetworkingReachabilityNotificationStatusItem";

typedef void (^BYNetworkReachabilityStatusBlock)(BYNetworkReachabilityStatus status);
typedef void (^BYNetworkReachabilityStatusAccessNameBlock)(NSString *accessName);

NSString * BYStringFromNetworkReachabilityStatus(BYNetworkReachabilityStatus status) {
    switch (status) {
        case BYNetworkReachabilityStatusNotReachable:
            return NSLocalizedStringFromTable(@"Not Reachable", @"BYNetworking", nil);
        case BYNetworkReachabilityStatusReachableViaWWAN2G:
            return NSLocalizedStringFromTable(@"Reachable via WWAN2G", @"BYNetworking", nil);
        case BYNetworkReachabilityStatusReachableViaWWAN3G:
            return NSLocalizedStringFromTable(@"Reachable via WWAN3G", @"BYNetworking", nil);
        case BYNetworkReachabilityStatusReachableViaWWAN4G:
            return NSLocalizedStringFromTable(@"Reachable via WWAN4G", @"BYNetworking", nil);
        case BYNetworkReachabilityStatusReachableViaWWANUnknownG:
            return NSLocalizedStringFromTable(@"Reachable via WWANUnknownG", @"BYNetworking", nil);
        case BYNetworkReachabilityStatusReachableViaWiFi:
            return NSLocalizedStringFromTable(@"Reachable via WiFi", @"BYNetworking", nil);
        case BYNetworkReachabilityStatusUnknown:
        default:
            return NSLocalizedStringFromTable(@"Unknown", @"BYNetworking", nil);
    }
}
/*
static BYNetworkReachabilityStatus BYNetworkReachabilityStatusForFlags(SCNetworkReachabilityFlags flags) {
    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    BOOL canConnectionAutomatically = (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) || ((flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0));
    BOOL canConnectWithoutUserInteraction = (canConnectionAutomatically && (flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0);
    BOOL isNetworkReachable = (isReachable && (!needsConnection || canConnectWithoutUserInteraction));
    
    BYNetworkReachabilityStatus status = BYNetworkReachabilityStatusUnknown;
    if (isNetworkReachable == NO) {
        status = BYNetworkReachabilityStatusNotReachable;
    }
#if    TARGET_OS_IPHONE
    else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {

        // ... but WWAN connections are OK if the calling application is using the CFNetwork APIs.
        NSArray *typeStrings2G = @[CTRadioAccessTechnologyEdge,
                                   CTRadioAccessTechnologyGPRS,
                                   CTRadioAccessTechnologyCDMA1x];
        
        NSArray *typeStrings3G = @[CTRadioAccessTechnologyHSDPA,
                                   CTRadioAccessTechnologyWCDMA,
                                   CTRadioAccessTechnologyHSUPA,
                                   CTRadioAccessTechnologyCDMAEVDORev0,
                                   CTRadioAccessTechnologyCDMAEVDORevA,
                                   CTRadioAccessTechnologyCDMAEVDORevB,
                                   CTRadioAccessTechnologyeHRPD];
        
        NSArray *typeStrings4G = @[CTRadioAccessTechnologyLTE];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            CTTelephonyNetworkInfo *teleInfo= [[CTTelephonyNetworkInfo alloc] init];
            NSString *accessString = teleInfo.currentRadioAccessTechnology;
            if ([typeStrings4G containsObject:accessString]) {
                status = BYNetworkReachabilityStatusReachableViaWWAN4G;
            } else if ([typeStrings3G containsObject:accessString]) {
                status = BYNetworkReachabilityStatusReachableViaWWAN3G;
            } else if ([typeStrings2G containsObject:accessString]) {
                status = BYNetworkReachabilityStatusReachableViaWWAN2G;
            } else {
                status = BYNetworkReachabilityStatusReachableViaWWANUnknownG;
            }
        } else {
            return BYNetworkReachabilityStatusReachableViaWWANUnknownG;
        }
    }
#endif
    else {
        status = BYNetworkReachabilityStatusReachableViaWiFi;
    }
    
    return status;
}
*/

static NSString *BYNetworkReachabilityRadioAccessTechnologyNameForFlags(SCNetworkReachabilityFlags flags) {
    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    BOOL canConnectionAutomatically = (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) || ((flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0));
    BOOL canConnectWithoutUserInteraction = (canConnectionAutomatically && (flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0);
    BOOL isNetworkReachable = (isReachable && (!needsConnection || canConnectWithoutUserInteraction));
    
    NSString *radioAccessName = @"unknown";//未知 和安卓定义的公共字符串
    if (isNetworkReachable == NO) {
        radioAccessName = @"notConnected";//未连接 和安卓定义的公共字符串
    }
#if    TARGET_OS_IPHONE
    else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
        /*
         ... but WWAN connections are OK if the calling application is using the CFNetwork APIs.
         
        NSArray *typeStrings2G = @[CTRadioAccessTechnologyEdge,
                                   CTRadioAccessTechnologyGPRS,
                                   CTRadioAccessTechnologyCDMA1x];
        
        NSArray *typeStrings3G = @[CTRadioAccessTechnologyHSDPA,
                                   CTRadioAccessTechnologyWCDMA,
                                   CTRadioAccessTechnologyHSUPA,
                                   CTRadioAccessTechnologyCDMAEVDORev0,
                                   CTRadioAccessTechnologyCDMAEVDORevA,
                                   CTRadioAccessTechnologyCDMAEVDORevB,
                                   CTRadioAccessTechnologyeHRPD];
        
        NSArray *typeStrings4G = @[CTRadioAccessTechnologyLTE];
         
        */
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            CTTelephonyNetworkInfo *teleInfo= [[CTTelephonyNetworkInfo alloc] init];
            NSString *iphoneAccessString = teleInfo.currentRadioAccessTechnology;
            if ([iphoneAccessString containsString:@"CTRadioAccessTechnology"]) {
                radioAccessName = [[iphoneAccessString stringByReplacingOccurrencesOfString:@"CTRadioAccessTechnology" withString:@""] uppercaseString];
            }else {
                radioAccessName = iphoneAccessString;
            }
        }
    }
#endif
    else {
        radioAccessName = @"wifi";
    }
    
    return radioAccessName;
}


/**
 * Queue a status change notification for the main thread.
 *
 * This is done to ensure that the notifications are received in the same order
 * as they are sent. If notifications are sent directly, it is possible that
 * a queued notification (for an earlier status condition) is processed BYter
 * the later update, resulting in the listener being left in the wrong state.
 */
static void BYPostReachabilityStatusChange(SCNetworkReachabilityFlags flags, BYNetworkReachabilityStatusAccessNameBlock block) {
//    BYNetworkReachabilityStatus status = BYNetworkReachabilityStatusForFlags(flags);
    NSString *accessName = BYNetworkReachabilityRadioAccessTechnologyNameForFlags(flags);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (block) {
            block(accessName);
        }
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        NSDictionary *userInfo = @{ BYNetworkingReachabilityNotificationStatusItem: accessName };
        [notificationCenter postNotificationName:BYNetworkingReachabilityDidChangeNotification object:nil userInfo:userInfo];
    });
}

static void BYNetworkReachabilityCallback(SCNetworkReachabilityRef __unused target, SCNetworkReachabilityFlags flags, void *info) {
    BYPostReachabilityStatusChange(flags, (__bridge BYNetworkReachabilityStatusAccessNameBlock)info);
}


static const void * BYNetworkReachabilityRetainCallback(const void *info) {
    return Block_copy(info);
}

static void BYNetworkReachabilityReleaseCallback(const void *info) {
    if (info) {
        Block_release(info);
    }
}

@interface BYStatNetworkReachabilityManager ()
@property (readonly, nonatomic, assign) SCNetworkReachabilityRef networkReachability;
@property (readwrite, nonatomic, assign) BYNetworkReachabilityStatus networkReachabilityStatus;
@property (readwrite, nonatomic, copy) NSString *radioAccessTechnologyName;
@property (readwrite, nonatomic, copy) BYNetworkReachabilityStatusBlock networkReachabilityStatusBlock;
@property (readwrite, nonatomic, copy) BYNetworkReachabilityStatusAccessNameBlock networkReachabilityStatusAccessNameBlock;
@end

@implementation BYStatNetworkReachabilityManager

+ (instancetype)sharedManager {
    static BYStatNetworkReachabilityManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [self manager];
    });
    
    return _sharedManager;
}

+ (instancetype)managerForDomain:(NSString *)domain {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [domain UTF8String]);
    
    BYStatNetworkReachabilityManager *manager = [[self alloc] initWithReachability:reachability];
    
    CFRelease(reachability);
    
    return manager;
}

+ (instancetype)managerForAddress:(const void *)address {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)address);
    BYStatNetworkReachabilityManager *manager = [[self alloc] initWithReachability:reachability];
    
    CFRelease(reachability);
    
    return manager;
}

+ (instancetype)manager
{
#if (defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED >= 90000) || (defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && __MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
    struct sockaddr_in6 address;
    bzero(&address, sizeof(address));
    address.sin6_len = sizeof(address);
    address.sin6_family = AF_INET6;
#else
    struct sockaddr_in address;
    bzero(&address, sizeof(address));
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;
#endif
    return [self managerForAddress:&address];
}

- (instancetype)initWithReachability:(SCNetworkReachabilityRef)reachability {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _networkReachability = CFRetain(reachability);
    self.networkReachabilityStatus = BYNetworkReachabilityStatusUnknown;
    
    return self;
}

- (instancetype)init NS_UNAVAILABLE
{
    return nil;
}

- (void)dealloc {
    [self stopMonitoring];
    
    if (_networkReachability != NULL) {
        CFRelease(_networkReachability);
    }
}

#pragma mark -

- (BOOL)isReachable {
    return [self isReachableViaWWAN] || [self isReachableViaWiFi];
}

- (BOOL)isReachableViaWWAN {
    return self.networkReachabilityStatus == BYNetworkReachabilityStatusReachableViaWWAN4G || self.networkReachabilityStatus == BYNetworkReachabilityStatusReachableViaWWAN3G || self.networkReachabilityStatus == BYNetworkReachabilityStatusReachableViaWWAN2G || self.networkReachabilityStatus == BYNetworkReachabilityStatusReachableViaWWANUnknownG;
}

- (BOOL)isReachableViaWiFi {
    return self.networkReachabilityStatus == BYNetworkReachabilityStatusReachableViaWiFi;
}

#pragma mark -

- (void)startMonitoring {
    [self stopMonitoring];
    
    if (!self.networkReachability) {
        return;
    }
    
//    __weak __typeof(self)weakSelf = self;
//    BYNetworkReachabilityStatusBlock callback = ^(BYNetworkReachabilityStatus status) {
//        __strong __typeof(weakSelf)strongSelf = weakSelf;
//
//        strongSelf.networkReachabilityStatus = status;
//        if (strongSelf.networkReachabilityStatusBlock) {
//            strongSelf.networkReachabilityStatusBlock(status);
//        }
//
//    };
    
    __weak __typeof(self)weakSelf = self;
    BYNetworkReachabilityStatusAccessNameBlock callback = ^(NSString *accessName) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        strongSelf.radioAccessTechnologyName = accessName;
        if (strongSelf.networkReachabilityStatusAccessNameBlock) {
            strongSelf.networkReachabilityStatusAccessNameBlock(accessName);
        }
    };

    SCNetworkReachabilityContext context = {0, (__bridge void *)callback, BYNetworkReachabilityRetainCallback, BYNetworkReachabilityReleaseCallback, NULL};
    SCNetworkReachabilitySetCallback(self.networkReachability, BYNetworkReachabilityCallback, &context);
    SCNetworkReachabilityScheduleWithRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(self.networkReachability, &flags)) {
            BYPostReachabilityStatusChange(flags, callback);
        }
    });
}

- (void)stopMonitoring {
    if (!self.networkReachability) {
        return;
    }
    
    SCNetworkReachabilityUnscheduleFromRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
}

#pragma mark -

- (NSString *)localizedNetworkReachabilityStatusString {
    return BYStringFromNetworkReachabilityStatus(self.networkReachabilityStatus);
}

#pragma mark -

- (void)setReachabilityStatusChangeBlock:(void (^)(BYNetworkReachabilityStatus status))block {
    self.networkReachabilityStatusBlock = block;
}

- (void)setReachabilityStatusChangeForAccessNameBlock:(nullable void (^)(NSString *accessName))block {
    self.networkReachabilityStatusAccessNameBlock = block;
}

#pragma mark - NSKeyValueObserving

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    if ([key isEqualToString:@"reachable"] || [key isEqualToString:@"reachableViaWWAN"] || [key isEqualToString:@"reachableViaWiFi"]) {
        return [NSSet setWithObject:@"networkReachabilityStatus"];
    }
    
    return [super keyPathsForValuesAffectingValueForKey:key];
}

@end
#endif
