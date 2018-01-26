//
//  NSMutableDictionary+BYStatSetObject.m
//  BYStat
//
//  Created by 许龙 on 2017/12/21.
//  Copyright © 2017年 QDHL. All rights reserved.
//

#import "NSMutableDictionary+BYStatSetObject.h"
#import <Foundation/Foundation.h>

@implementation NSMutableDictionary (BYStatSetObject)

- (void)byStat_setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if (anObject == nil) {
        [self setObject:@"" forKey:aKey];
    }else {
        [self setObject:anObject forKey:aKey];
    }
}


@end
