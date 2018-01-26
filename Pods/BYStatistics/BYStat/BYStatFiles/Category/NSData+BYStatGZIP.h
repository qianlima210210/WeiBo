//
//  NSData+BYStatGZIP.h
//  BYStat
//
//  Created by 许龙 on 2017/12/27.
//  Copyright © 2017年 QDHL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (BYStatGZIP)

- (nullable NSData *)gzippedDataWithCompressionLevel:(float)level;
- (nullable NSData *)gzippedData;
- (nullable NSData *)gunzippedData;
- (BOOL)isGzippedData;


@end
