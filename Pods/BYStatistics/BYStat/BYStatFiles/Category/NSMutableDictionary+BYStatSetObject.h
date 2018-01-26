//
//  NSMutableDictionary+BYStatSetObject.h
//  BYStat
//
//  Created by 许龙 on 2017/12/21.
//  Copyright © 2017年 QDHL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (BYStatSetObject)


- (void)byStat_setObject:(id)anObject forKey:(id<NSCopying>)aKey;


@end
