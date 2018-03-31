//
//  NSAttributedString+AttributedStringHeight.h
//  BYChatLabelDemo
//
//  Created by QDHL on 2018/3/13.
//  Copyright © 2018年 QDHL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSAttributedString (AttributedStringHeight)

/**
 获取属性字符串的高度
 @param size 范围
 @param font 字体
 @param lineSpacing 行间距
 @return 高度
 */
-(CGFloat)heightOfAttributedStringWithSize:(CGSize)size font:(UIFont*)font lineSpacing:(CGFloat)lineSpacing;
    
@end
