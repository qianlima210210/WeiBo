//
//  Emotion.swift
//  Swift图文混排
//
//  Created by QDHL on 2018/3/30.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit
import YYModel


/// 表情模型
@objcMembers class Emotion: NSObject {

    /// 表情类型：false是图片表情；true是emoj表情
    var type = false
    
    /// 表情名字符串，用于发送给服务器（这样就节约流量了）
    var chs: String?
    
    /// 表情图片所在目录
    var directory: String?
    
    /// 表情图片名，用于本地图文混排
    var png: String?
    
    /// emoji表情的十六进制编码
    var code: String?
    
    /// 图片表情对应的图片
    var image: UIImage? {
        if type {
            return nil
        }
        
        guard let path = Bundle.main.path(forResource: "MQLEmotions.bundle", ofType: nil),
            let bundle = Bundle.init(path: path),
            let directory = directory,
            let png = png else {
                return nil
        }
        
        return UIImage.init(named: "\(directory)/\(png)", in: bundle, compatibleWith: nil)
    }
    
    
    /// 图片属性字符串
    ///
    /// - Parameter font: 用来计算行高
    /// - Returns:图片属性字符串
    func imageAttributeString(font: UIFont) -> NSAttributedString? {
        guard let image = image else { return nil }
        
        //创建文本附件
        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(x: 0.0, y: -4.0, width: font.lineHeight, height: font.lineHeight)
        
        return NSAttributedString(attachment: attachment)
    }
    
    override var description: String {
        return yy_modelDescription()
    }
}
