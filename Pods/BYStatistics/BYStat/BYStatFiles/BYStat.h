//
//  BYStat.h
//  BYStat
//
//  Created by QDHL on 2017/11/28.
//  Copyright © 2017年 QDHL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class WKWebView;
NS_ASSUME_NONNULL_BEGIN
@interface BYStat : NSObject

/**
 初始化百佑所有组件产品，开启统计操作。
 
 @param appKey 开发者在百佑官网申请的appkey.
 @param channel 渠道标识，可设置nil表示"App Store".
 */
+ (void)startWithAppkey:(NSString *)appKey channel:(nullable NSString *)channel;

/**
 停止统计，**慎用** 停止统计sdk做的一切操作：写入数据库，监听应用打开和关闭，上传统计数据
 */
+ (void)stopStatistics;

/**
 是否调试模式，默认：NO
 若为YES，调试模式，SDK将统计数据发送到回传测试服务器供查看、调试是否配置正确；同时会打开SDK日志打印功能；
 若为NO，非调试模式，SDK将统计数据发送到正式环境；同时关闭SDK日志打印功能。
 ---- 正式发布,Release模式下一定将此属性设置为非debug模式，即：NO ----
 */
+ (void)setDebugEnabled:(BOOL)debugEnable;

#pragma mark - 统计应用的打开方式

/**
 统计应用的打开方式,如需使用添加在app didFinishLaunch方法中添加

 @param additionDict 打开应用的方式,3Dtouch, 第三方跳转,快捷方式等
 */
+ (void)openApplicationTypeWithAdditionInfo:(nullable NSDictionary *)additionDict;

#pragma mark - 账号统计

/**
 统计账号信息
 
 @param userId 应用分配的userId, 若为空,就不统计该条数据
 @param provider 账号来源, 微信, 新浪, qq等第三方来源, 若为空,则默认为手机号登录
 @param additionDict 额外信息 说明只支持字符串基本类型
 */
+ (void)signInWithUserId:(NSString *)userId provider:(NSString *)provider additionInfo:(nullable NSDictionary *)additionDict;

/**
 统计账号信息  退出账号，如果没有登录状态下调用此接口，不会统计任何信息
 
 @param additionDict 额外信息
 */
+ (void)signOffWithAdditionInfo:(nullable NSDictionary *)additionDict;

#pragma mark - 页面统计接口
/**
 @name  页面计时
 自动页面时长统计, 开始记录某个页面展示时长.
 使用方法：必须配对调用beginLogPageView:和endLogPageView:两个函数来完成自动统计，若只调用某一个函数不会生成有效数据。
 在该页面展示时调用beginLogPageView:，当退出该页面时调用endLogPageView:
 
 @param pageViewId 统计的页面名称,若为空,则不统计该项数据
 @param additionDict 其它信息map/Dictionary 说明只支持字符串基本类型
 */
+ (void)beginLogPageView:(NSString *)pageViewId additionInfo:(nullable NSDictionary *)additionDict;

/**
 自动页面时长统计, 结束记录某个页面展示时长.
 使用方法：必须配对调用beginLogPageView:和endLogPageView:两个函数来完成自动统计，若只调用某一个函数不会生成有效数据。
 在该页面展示时调用beginLogPageView:，当退出该页面时调用endLogPageView:
 
 @param pageViewId 统计的页面名称.若为空,则不统计该项数据
 @param additionDict 其它信息map/Dictionary 说明只支持字符串基本类型
 */
+ (void)endLogPageView:(NSString *)pageViewId additionInfo:(nullable NSDictionary *)additionDict;

#pragma mark - 事件统计
/**
 自定义事件,数量统计.
 使用前，请先到友盟App管理后台的设置->编辑自定义事件 中添加相应的事件ID，然后在工程中传入相应的事件ID
 
 @param eventId 事件id. 若为空,则不统计该项数据
 @param additionDict 额外信息. 说明只支持字符串基本类型
 */
+ (void)event:(NSString *)eventId additionInfo:(nullable NSDictionary *)additionDict;



#pragma mark - 地理位置设置
/**
 设置经纬度信息
 需要链接 CoreLocation.framework 并且 #import <CoreLocation/CoreLocation.h>
 
 @param latitude 纬度.  若为空,则不统计该项数据
 @param longitude 经度. 若为空,则不统计该项数据
 @param additionDict 其它信息map/Dictionary 说明只支持字符串基本类型
 */
+ (void)setLatitude:(double)latitude longitude:(double)longitude additionInfo:(nullable NSDictionary *)additionDict;


#pragma mark - UIWebView统计
/**
 要统计UIWebView的页面时，在UIWebView的代理方法shouldStartLoadWithRequest中调用此方法，
 使用[[[request URL] absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]截取的参数funcStr

 @param funcStr 从url中截取的funcStr
 @param webView 使用的UIWebView
 @return 能匹配到统计方法返回NO，否则YES
 */
+ (BOOL)execute:(NSString *)funcStr inUIWebView:(UIWebView *)webView;


#pragma mark - WKWebView统计
/**
 要统计WKWebView的页面时，在WKWebView的代理方法中decidePolicyForNavigationAction中调用
 NSString *url = [navigationAction.request.URL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
 NSString *funcStr = [url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
 
 @param funcStr 从url中截取的funcStr
 @param webView 使用的WKWebView
 @return 能匹配到统计方法返回NO，否则YES
 */
+ (BOOL)execute:(NSString *)funcStr inWKWebView:(WKWebView *)webView;


#pragma mark - Other
/**
 加载js文件的路径

 @return js资源路径
 */
+ (NSString *)jsPath;



@end
NS_ASSUME_NONNULL_END


