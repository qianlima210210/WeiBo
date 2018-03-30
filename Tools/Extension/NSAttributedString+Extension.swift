//
//  NSAttributedString+Extension.swift
//  WeiBo
//
//  Created by QDHL on 2018/3/30.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

extension NSAttributedString {
    /**
     获取字符串高度
     这里有个小知识点：font.lineHeight + lineSpacing 等于一行高度rect.height
     @param size 限制区域
     @param font 字体
     @param lineSpacing 行间距
     @return 字符串高度
     */
    func heightOfString(size:CGSize, font:UIFont, lineSpacing:CGFloat) -> CGFloat {
        if (self.length == 0) {
            return CGFloat(0.0);
        }
        
        let rect =  self.boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil)
        return  ((font.lineHeight + lineSpacing) != rect.height) ? ceil(rect.height) + 1.0 : font.lineHeight
    }
    
}




