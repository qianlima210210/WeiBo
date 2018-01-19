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
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpacing;
        let attributes = [NSAttributedStringKey.font:font, NSAttributedStringKey.paragraphStyle:style]
        
        let opts = NSStringDrawingOptions.usesLineFragmentOrigin
        let rect = self.boundingRect(with: size, options: opts, attributes: attributes, context: nil)
        
        return rect.height
    }
    
}







