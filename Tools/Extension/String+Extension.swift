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
     这里有个小知识点：font.lineHeight + lineSpacing 等于一行高度rect.height
     @param size 限制区域
     @param font 字体
     @param lineSpacing 行间距
     @return 字符串高度
     */
    func heightOfString(size:CGSize, font:UIFont, lineSpacing:CGFloat) -> CGFloat {
        if (self.count == 0) {
            return CGFloat(0.0);
        }

        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpacing;
        let attributes = [NSAttributedStringKey.font:font, NSAttributedStringKey.paragraphStyle:style]
        let attStr = NSAttributedString(string: self, attributes: attributes)
        
        let rect =  attStr.boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil)
        return  ((font.lineHeight + lineSpacing) != rect.height) ? ceil(rect.height) + 1.0 : font.lineHeight
    }
    
    /// 获取地址、名称
    ///
    /// - Returns: 地址、名称元组
    func hrefAndName() -> (href: String?, name: String?)? {
        let pattern = "<a href=\"(.*?)\".*?>(.*?)</a>"
        let regx = try? NSRegularExpression(pattern: pattern)
        
        guard let result = regx?.firstMatch(in: self, options: [], range: NSMakeRange(0, self.count)) else{
            return nil
        }
        
        let href = (self as NSString).substring(with: result.range(at: 1))
        let name = (self as NSString).substring(with: result.range(at: 2))
        
        return (href, name)
    }
    
}







