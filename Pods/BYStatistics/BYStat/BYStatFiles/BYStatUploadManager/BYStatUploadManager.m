//
//  BYStatUploadManager.m
//  BYStat
//
//  Created by Robin on 2017/11/28.
//  Copyright © 2017年 QDHL. All rights reserved.
//

#import "BYStatUploadManager.h"
#import "BYStatCommonDefine.h"

@implementation BYStatUploadManager


/**
 发送网络上传的post请求
 
 @param url 地址
 @param header 请求头
 @param bodyData 请求体
 @param successBlock 成功的回调
 @param failureBlock 失败的回调
 */
+ (void)postRequestUploadDataWithUrl:(NSString *)url header:(NSDictionary *)header body:(NSData *)bodyData success:(BYStatUploadSuccessBlock)successBlock failure:(BYStatUploadFailreBlock)failureBlock
{
    NSURL *nsurl = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:nsurl];
    NSDictionary *headers = header;
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    [request setHTTPBody:bodyData];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *dataTask = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                if (error) {
                                                    failureBlock(error);
                                                }else {// 请求成功
                                                    successBlock(data);
                                                }
                                            }];
    [dataTask resume];
}



@end
