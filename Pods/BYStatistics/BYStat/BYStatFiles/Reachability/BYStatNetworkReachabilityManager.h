//
//  BYNetworkReachabilityManager.h
//  BYStat
//
//  Created by 许龙 on 2017/11/29.
//  Copyright © 2017年 QDHL. All rights reserved.
//

#import <Foundation/Foundation.h>

#if !TARGET_OS_WATCH
#import <SystemConfiguration/SystemConfiguration.h>

typedef NS_ENUM(NSInteger, BYNetworkReachabilityStatus) {
    BYNetworkReachabilityStatusUnknown          = -1,
    BYNetworkReachabilityStatusNotReachable     = 0,
    BYNetworkReachabilityStatusReachableViaWWAN2G = 1,
    BYNetworkReachabilityStatusReachableViaWWAN3G = 2,
    BYNetworkReachabilityStatusReachableViaWWAN4G = 3,
    BYNetworkReachabilityStatusReachableViaWWANUnknownG = 4,
    BYNetworkReachabilityStatusReachableViaWiFi = 5,
};

NS_ASSUME_NONNULL_BEGIN

/**
 `BYNetworkReachabilityManager` monitors the reachability of domains, and addresses for both WWAN and WiFi network interfaces.
 
 Reachability can be used to determine background information about why a network operation failed, or to trigger a network operation retrying when a connection is established. It should not be used to prevent a user from initiating a network request, as it's possible that an initial request may be required to establish reachability.
 
 See Apple's Reachability Sample Code ( https://developer.apple.com/library/ios/samplecode/reachability/ )
 
 @warning Instances of `BYNetworkReachabilityManager` must be started with `-startMonitoring` before reachability status can be determined.
 */
@interface BYStatNetworkReachabilityManager : NSObject

/**
 The current network reachability status.
 */
@property (readonly, nonatomic, assign) BYNetworkReachabilityStatus networkReachabilityStatus;

/**
 网络制式名称 LTE、GPRS等
 */
@property (readonly, nonatomic, copy  ) NSString *radioAccessTechnologyName;

/**
 Whether or not the network is currently reachable.
 */
@property (readonly, nonatomic, assign, getter = isReachable) BOOL reachable;

/**
 Whether or not the network is currently reachable via WWAN.
 */
@property (readonly, nonatomic, assign, getter = isReachableViaWWAN) BOOL reachableViaWWAN;

/**
 Whether or not the network is currently reachable via WiFi.
 */
@property (readonly, nonatomic, assign, getter = isReachableViaWiFi) BOOL reachableViaWiFi;

///---------------------
/// @name Initialization
///---------------------

/**
 Returns the shared network reachability manager.
 */
+ (instancetype)sharedManager;

/**
 Creates and returns a network reachability manager with the default socket address.
 
 @return An initialized network reachability manager, actively monitoring the default socket address.
 */
+ (instancetype)manager;

/**
 Creates and returns a network reachability manager for the specified domain.
 
 @param domain The domain used to evaluate network reachability.
 
 @return An initialized network reachability manager, actively monitoring the specified domain.
 */
+ (instancetype)managerForDomain:(NSString *)domain;

/**
 Creates and returns a network reachability manager for the socket address.
 
 @param address The socket address (`sockaddr_in6`) used to evaluate network reachability.
 
 @return An initialized network reachability manager, actively monitoring the specified socket address.
 */
+ (instancetype)managerForAddress:(const void *)address;

/**
 Initializes an instance of a network reachability manager from the specified reachability object.
 
 @param reachability The reachability object to monitor.
 
 @return An initialized network reachability manager, actively monitoring the specified reachability.
 */
- (instancetype)initWithReachability:(SCNetworkReachabilityRef)reachability NS_DESIGNATED_INITIALIZER;

///--------------------------------------------------
/// @name Starting & Stopping Reachability Monitoring
///--------------------------------------------------

/**
 Starts monitoring for changes in network reachability status.
 */
- (void)startMonitoring;

/**
 Stops monitoring for changes in network reachability status.
 */
- (void)stopMonitoring;

///-------------------------------------------------
/// @name Getting Localized Reachability Description
///-------------------------------------------------

/**
 Returns a localized string representation of the current network reachability status.
 */
- (NSString *)localizedNetworkReachabilityStatusString;

///---------------------------------------------------
/// @name Setting Network Reachability Change Callback
///---------------------------------------------------

/**
 Sets a callback to be executed when the network availability of the `baseURL` host changes.
 
 @param block A block object to be executed when the network availability of the `baseURL` host changes.. This block has no return value and takes a single argument which represents the various reachability states from the device to the `baseURL`.
 */
- (void)setReachabilityStatusChangeBlock:(nullable void (^)(BYNetworkReachabilityStatus status))block;

- (void)setReachabilityStatusChangeForAccessNameBlock:(nullable void (^)(NSString *accessName))block;


@end

///----------------
/// @name Constants
///----------------

/**
 ## Network Reachability
 
 The following constants are provided by `BYNetworkReachabilityManager` as possible network reachability statuses.
 
 enum {
 BYNetworkReachabilityStatusUnknown,
 BYNetworkReachabilityStatusNotReachable,
 BYNetworkReachabilityStatusReachableViaWWAN,
 BYNetworkReachabilityStatusReachableViaWiFi,
 }
 
 `BYNetworkReachabilityStatusUnknown`
 The `baseURL` host reachability is not known.
 
 `BYNetworkReachabilityStatusNotReachable`
 The `baseURL` host cannot be reached.
 
 `BYNetworkReachabilityStatusReachableViaWWAN`
 The `baseURL` host can be reached via a cellular connection, such as EDGE or GPRS.
 
 `BYNetworkReachabilityStatusReachableViaWiFi`
 The `baseURL` host can be reached via a Wi-Fi connection.
 
 ### Keys for Notification UserInfo Dictionary
 
 Strings that are used as keys in a `userInfo` dictionary in a network reachability status change notification.
 
 `BYNetworkingReachabilityNotificationStatusItem`
 A key in the userInfo dictionary in a `BYNetworkingReachabilityDidChangeNotification` notification.
 The corresponding value is an `NSNumber` object representing the `BYNetworkReachabilityStatus` value for the current reachability status.
 */

///--------------------
/// @name Notifications
///--------------------

/**
 Posted when network reachability changes.
 This notification assigns no notification object. The `userInfo` dictionary contains an `NSNumber` object under the `BYNetworkingReachabilityNotificationStatusItem` key, representing the `BYNetworkReachabilityStatus` value for the current network reachability.
 
 @warning In order for network reachability to be monitored, include the `SystemConfiguration` framework in the active target's "Link Binary With Library" build phase, and add `#import <SystemConfiguration/SystemConfiguration.h>` to the header prefix of the project (`Prefix.pch`).
 */
FOUNDATION_EXPORT NSString * const BYNetworkingReachabilityDidChangeNotification;
FOUNDATION_EXPORT NSString * const BYNetworkingReachabilityNotificationStatusItem;

///--------------------
/// @name Functions
///--------------------

/**
 Returns a localized string representation of an `BYNetworkReachabilityStatus` value.
 */
FOUNDATION_EXPORT NSString * BYStringFromNetworkReachabilityStatus(BYNetworkReachabilityStatus status);

NS_ASSUME_NONNULL_END
#endif
