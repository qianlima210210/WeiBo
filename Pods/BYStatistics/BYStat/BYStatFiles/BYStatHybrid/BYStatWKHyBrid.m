//
//  BYStatWKHyBrid.m
//  BYStatistics
//
//  Created by Robin on 2017/12/21.
//

#import "BYStatWKHyBrid.h"
#import <BYStatistics/BYStat.h>

#define kParametersPrefixLength  13

static BYStatWKHyBrid *byHyhrid = nil;

@implementation BYStatWKHyBrid

+ (BOOL)execute:(NSString *)parameters webView:(WKWebView *)webView {
    if ([parameters hasPrefix:@"qdstatistics"]) {
        if (nil == byHyhrid) {
            byHyhrid = [[BYStatWKHyBrid alloc] init];
        }
        NSString *str = [parameters substringFromIndex:kParametersPrefixLength];
        NSDictionary *dic = [self jsonToDictionary:str];
        NSString *functionName = [dic objectForKey:@"functionName"];
        NSArray *args = [dic objectForKey:@"arguments"];
        if ([functionName isEqualToString:@"getDeviceId"]) {
            [byHyhrid getDeviceId:args webView:webView];
        } else {
            SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@:", functionName]);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            if ([byHyhrid respondsToSelector:selector]) {
                [byHyhrid performSelector:selector withObject:args];
            }
#pragma clang diagnostic pop
        }
        return YES;
    }
    
    return NO;
}

+ (NSDictionary *)jsonToDictionary:(NSString *)jsonStr {
    if (jsonStr) {
        NSError* error = nil;
        id object = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (error == nil && [object isKindOfClass:[NSDictionary class]]) {
            return object;
        }
    }
    
    return nil;
}


- (void)getDeviceId:(NSArray *)arguments webView:(WKWebView *)webView {
    NSString *arg0 = [arguments objectAtIndex:0];
    if (arg0 == nil || [arg0 isKindOfClass:[NSNull class]] || arg0.length == 0) {
        return;
    }
    
    NSString *deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *callBack = [NSString stringWithFormat:@"%@('%@')", arg0, deviceId];
    [webView evaluateJavaScript:callBack completionHandler:^(id _Nullable response, NSError * _Nullable error) {
    }];
    
}

- (void)onEvent:(NSArray *)arguments {
    NSString *eventId = [arguments objectAtIndex:0];
    if (eventId == nil || [eventId isKindOfClass:[NSNull class]]) {
        return;
    }
    NSDictionary *addiDict = nil;
    if (arguments.count > 1) {
        addiDict = [arguments objectAtIndex:1];
    }
    [BYStat event:eventId additionInfo:addiDict];
}


- (void)onPageStart:(NSArray *)arguments {
    NSString *pageName = [arguments objectAtIndex:0];
    NSDictionary *addiDict = nil;
    if (arguments.count > 1) {
        addiDict = [arguments objectAtIndex:1];
    }
    if (pageName == nil || [pageName isKindOfClass:[NSNull class]]) {
        return;
    }
    [BYStat beginLogPageView:pageName additionInfo:addiDict];
}

- (void)onPageEnd:(NSArray *)arguments {
    NSString *pageName = [arguments objectAtIndex:0];
    NSDictionary *addiDict = nil;
    if (arguments.count > 1) {
        addiDict = [arguments objectAtIndex:1];
    }
    if (pageName == nil || [pageName isKindOfClass:[NSNull class]]) {
        return;
    }
    [BYStat endLogPageView:pageName additionInfo:addiDict];
}

@end
