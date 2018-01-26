//
//  BYEncryptHelper.h
//
//
//  Created by zhoucy on 15/5/29.
//  Copyright (c) 2015年 www.qdingnet.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BYStatEncryptHelper : NSObject

/**
 版本号
 
 @return 版本号（v0.1.0 Build 119193）
 */

+ (nonnull NSString *)version;


/**
 创建传输时的秘钥

 @return 长度为16的字符串
 */
+ (nonnull NSString *)createSecretKey;


/**
 对字符串进行加密

 @param string 明文字符串
 @param key 传输时的秘钥
 @return 密文字符串
 */
+ (nullable NSString *)encrypt:(nonnull NSString*)string key:(nonnull NSString*)key;


/**
 对字符串进行解密

 @param string 密文字符串
 @param key 传输时的秘钥
 @return 明文字符串
 */
+ (nullable NSString *)decrypt:(nonnull NSString*)string key:(nonnull NSString*)key;


/**
 http加密获取signCode的方法

 @param string 字符串
 @return 字符串对应的签名
 */
+ (nullable NSString *)signCodeWithString:(nonnull NSString *)string;

/**
 使用key对data进行HMAC_SHA1加密
 
 @param key key字符串
 @param data data字符串
 @return 加密结果
 */
+ (nonnull NSString *)HMAC_SHA1WithKey:(nonnull NSString *)key
                                  data:(nonnull NSString *)data;

@end



