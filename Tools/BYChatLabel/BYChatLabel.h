//
//  BYChatLabel.h
//  BYChatLabelDemo
//
//  Created by QDHL on 2018/3/13.
//  Copyright © 2018年 QDHL. All rights reserved.
//

#import <UIKit/UIKit.h>

//被点击类型
typedef enum : NSUInteger {
    BYURLClickedTypeOnChatLabel,        //网址被点击
    BYPhoneNumClickedTypeOnChatLabel,   //电话号码被点击
    BYEmailClickedTypeOnChatLabel,      //邮件地址被点击
} BYClickedTypeOnChatLabel;

@interface BYChatLabel : UILabel

//TextKit核心对象
@property (nonatomic, strong) NSTextStorage *textStorage;       //存放属性字符串及一组NSLayoutManager对象
@property (nonatomic, strong) NSLayoutManager *layoutManager;   //字形管理对象，形成TextView，并显示到NSTextContainer
@property (nonatomic, strong) NSTextContainer *textContainer;   //属性字符串绘制范围
    
@end
