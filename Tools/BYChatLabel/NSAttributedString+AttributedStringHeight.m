//
//  NSAttributedString+AttributedStringHeight.m
//  BYChatLabelDemo
//
//  Created by QDHL on 2018/3/13.
//  Copyright © 2018年 QDHL. All rights reserved.
//

#import "NSAttributedString+AttributedStringHeight.h"

@implementation NSAttributedString (AttributedStringHeight)

/**
 获取属性字符串的高度
 @param size 范围
 @param font 字体
  @param lineSpacing 行间距
 @return 高度
 */
-(CGFloat)heightOfAttributedStringWithSize:(CGSize)size font:(UIFont*)font lineSpacing:(CGFloat)lineSpacing{
    
    if (self.length == 0) {
        return 0.0;
    }
    
    CGRect rect = [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    return  ((font.lineHeight + lineSpacing) != rect.size.height) ? ceil(rect.size.height) + 1.0 : font.lineHeight;
}

@end





























