//
//  String+Extension.swift
//  WeiBo
//
//  Created by QDHL on 2018/1/11.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

extension String {
    /**
     获取字符串高度
     
     @param size 限制区域
     @param font 字体
     @param lineSpacing 行间距
     @return 字符串高度
     */
    func heightOfString(size:CGSize, font:UIFont, lineSpacing:CGFloat) -> CGFloat {
        //先获取单行文本的高度
        let sizeOfSingleLine: CGSize = self.size(withAttributes: [NSAttributedStringKey.font:font])
        let singleLineHeight = sizeOfSingleLine.height
        
        //再获取多行文本的高度
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpacing;
        let attributes = [NSAttributedStringKey.font:font, NSAttributedStringKey.paragraphStyle:style]
        
        let opts = NSStringDrawingOptions.usesLineFragmentOrigin
        let rect = self.boundingRect(with: size, options: opts, attributes: attributes, context: nil)
        
        let multiLineHeight = rect.height
        
        //最后决定，到底返回单行高度还是多行高度
        if sizeOfSingleLine.width >= size.width {//应该分为多行
            return multiLineHeight
        }else{
            return singleLineHeight
        }
        
    }
    
}







