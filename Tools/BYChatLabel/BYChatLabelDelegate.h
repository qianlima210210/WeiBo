//
//  BYChatLabelDelegate.h
//  WeiBo
//
//  Created by QDHL on 2018/3/31.
//  Copyright © 2018年 QDHL. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BYChatLabel;

@protocol BYChatLabelDelegate <NSObject>

@optional
-(void)chatLabelURLClicked:(BYChatLabel*)chatLabel string:(NSString*)string;

-(void)chatLabelPhoneNumClicked:(BYChatLabel*)chatLabel string:(NSString*)string;

-(void)chatLabelEmailClicked:(BYChatLabel*)chatLabel string:(NSString*)string;

@end
