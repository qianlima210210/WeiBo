//
//  BYStatUploadManager.h
//  BYStat
//
//  Created by Robin on 2017/11/28.
//  Copyright © 2017年 QDHL. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^BYStatUploadSuccessBlock)(NSData *data);

typedef void (^BYStatUploadFailreBlock)(NSError *error);


@interface BYStatUploadManager : NSObject

/**
 发送网络上传的post请求

 @param url 地址
 @param header 请求头
 @param bodyData 请求体GZIPData
 @param successBlock 成功的回调
 @param failureBlock 失败的回调
 */
+ (void)postRequestUploadDataWithUrl:(NSString *)url header:(NSDictionary *)header body:(NSData *)bodyData success:(BYStatUploadSuccessBlock)successBlock failure:(BYStatUploadFailreBlock)failureBlock;





@end
