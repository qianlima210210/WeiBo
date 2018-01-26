//
//  BYStat.m
//  BYStat
//
//  Created by QDHL on 2017/11/28.
//  Copyright © 2017年 QDHL. All rights reserved.
//

#import <BYStatistics/BYStat.h>
#import "BYStatDataHandleManager.h"
#import "BYStatHybrid.h"
#import "BYStatWKHybrid.h"
#import <WebKit/WebKit.h>

//是否开启统计的全局变量
static BOOL isStartStatistics = NO;

@implementation BYStat

/**
 初始化百佑所有组件产品
 
 @param appKey 开发者在百佑官网申请的appkey.
 @param channel 渠道标识，可设置nil表示"App Store".
 */
+ (void)startWithAppkey:(NSString *)appKey channel:(NSString *)channel
{
    isStartStatistics = YES;
    [[BYStatDataHandleManager shareDataHandleManager] handleConfigureBasicInfoWithApplicationName:appKey applicationChannel:channel];
    
    [[BYStatDataHandleManager shareDataHandleManager] handleOpenApplicationWithAdditionalInfo:nil];
}

/**
 关闭统计操作
 */
+ (void)stopStatistics {
    if (isStartStatistics) {
        isStartStatistics = NO;
        [[BYStatDataHandleManager shareDataHandleManager] closeListenApplicationAndNetwork];
    }
}

/**
 统计应用的打开方式,如需使用添加在app didFinishLaunch方法中添加
 
 @param additionDict 打开应用的方式,3Dtouch, 第三方跳转,快捷方式等
 */
+ (void)openApplicationTypeWithAdditionInfo:(nullable NSDictionary *)additionDict
{
    if (!isStartStatistics) { return; }
    [[BYStatDataHandleManager shareDataHandleManager] handleOpenApplicationWithAdditionalInfo:additionDict];
}

#pragma mark - 账号统计

/**
 统计账号信息
 
 @param userId 应用分配的userId, 若为空,就不统计该条数据
 @param provider 账号来源, 微信, 新浪, qq等第三方来源, 若为空,则默认为手机号登录
 @param additionDict 额外信息 说明只支持字符串基本类型
 */
+ (void)signInWithUserId:(NSString *)userId provider:(NSString *)provider additionInfo:(NSDictionary *)additionDict
{
    if (!isStartStatistics) { return; }
    [[BYStatDataHandleManager shareDataHandleManager] handleSignInWithUserId:userId provider:provider additionalInfo:additionDict];
}

/**
 统计账号信息  退出账号
 
 @param additionDict 额外信息
 */
+ (void)signOffWithAdditionInfo:(NSDictionary *)additionDict
{
    if (!isStartStatistics) { return; }
    [[BYStatDataHandleManager shareDataHandleManager] handleSignOffWithAdditionalInfo:additionDict];
}


/**
 是否调试模式，默认：NO
 若为YES，调试模式，SDK将统计数据发送到回传测试服务器供查看、调试是否配置正确；同时会打开SDK日志打印功能；
 若为NO，非调试模式，SDK将统计数据发送到正式环境；同时关闭SDK日志打印功能。
 ---- 正式发布,Release模式下一定将此属性设置为非debug模式，即：NO ----
 */
+ (void)setDebugEnabled:(BOOL)debugEnable
{
    BYStatDataHandleManager *dataManager = [BYStatDataHandleManager shareDataHandleManager];
    dataManager.byStatDebug = debugEnable;
}

#pragma mark - 页面统计接口
/**
 @name  页面计时
 自动页面时长统计, 开始记录某个页面展示时长.
 使用方法：必须配对调用beginLogPageView:和endLogPageView:两个函数来完成自动统计，若只调用某一个函数不会生成有效数据。
 在该页面展示时调用beginLogPageView:，当退出该页面时调用endLogPageView:
 
 @param pageViewId 统计的页面名称,若为空,则不统计该项数据
 @param additionDict 其它信息map/Dictionary 说明只支持字符串基本类型
 */
+ (void)beginLogPageView:(NSString *)pageViewId additionInfo:(NSDictionary *)additionDict
{
    if (!isStartStatistics) { return; }
    [[BYStatDataHandleManager shareDataHandleManager] handleBeginLogPageView:pageViewId additionalInfo:additionDict];
}

/**
 自动页面时长统计, 结束记录某个页面展示时长.
 使用方法：必须配对调用beginLogPageView:和endLogPageView:两个函数来完成自动统计，若只调用某一个函数不会生成有效数据。
 在该页面展示时调用beginLogPageView:，当退出该页面时调用endLogPageView:
 
 @param pageViewId 统计的页面名称.若为空,则不统计该项数据
 @param additionDict 其它信息map/Dictionary 说明只支持字符串基本类型
 */
+ (void)endLogPageView:(NSString *)pageViewId additionInfo:(NSDictionary *)additionDict
{
    if (!isStartStatistics) { return; }
    [[BYStatDataHandleManager shareDataHandleManager] handleEndLogPageView:pageViewId additionalInfo:additionDict];
}


#pragma mark - 事件统计
/**
 自定义事件,数量统计.
 使用前，请先到友盟App管理后台的设置->编辑自定义事件 中添加相应的事件ID，然后在工程中传入相应的事件ID
 
 @param eventId 事件id. 若为空,则不统计该项数据
 @param additionDict 额外信息. 说明只支持字符串基本类型
 */
+ (void)event:(NSString *)eventId additionInfo:(NSDictionary *)additionDict
{
    if (!isStartStatistics) { return; }
    [[BYStatDataHandleManager shareDataHandleManager] handleEvent:eventId additionalInfo:additionDict];
}

#pragma mark - 地理位置设置
/**
 设置经纬度信息
 需要链接 CoreLocation.framework 并且 #import <CoreLocation/CoreLocation.h>
 
 @param latitude 纬度.  若为空,则不统计该项数据
 @param longitude 经度. 若为空,则不统计该项数据
 @param additionDict 其它信息map/Dictionary 说明只支持字符串基本类型
 */
+ (void)setLatitude:(double)latitude longitude:(double)longitude additionInfo:(NSDictionary *)additionDict
{
    if (!isStartStatistics) { return; }
    [[BYStatDataHandleManager shareDataHandleManager] handlePositionLatitude:latitude longitude:longitude additionalInfo:additionDict];
}


#pragma mark - UIWebView统计
+ (BOOL)execute:(NSString *)funcStr inUIWebView:(UIWebView *)webView {
    return [BYStatHybrid execute:funcStr webView:webView];
}

#pragma mark - WkWebView统计
+ (BOOL)execute:(NSString *)funcStr inWKWebView:(WKWebView *)webView {
    return [BYStatWKHyBrid execute:funcStr webView:webView];
}

#pragma mark - Other
+ (NSString *)jsPath {
    NSURL *bundleUrl = [[NSBundle bundleForClass:[BYStat class]] URLForResource:@"BYStat" withExtension:@"bundle"];
    NSBundle *sourceBundle = [NSBundle bundleWithURL:bundleUrl];
    NSString * jsPath = [sourceBundle pathForResource:@"QDStatistics" ofType:@"js"];
    return jsPath;
}

@end
