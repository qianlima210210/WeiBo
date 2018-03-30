//
//  EmotionsManager.swift
//  Swift图文混排
//
//  Created by QDHL on 2018/3/29.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit
import YYModel

/// 表情管理器
class EmotionsManager {
    
    //表情管理器单例
    static let emotionsManager = EmotionsManager()
    
    var emotionPackages = [EmotionPackage]()
    
    /// 禁止外部创建（这样保证了单例）
    private init(){
        loadEmoticonsPlistFileInfo()
    }
}

// MARK: 表情符号处理
extension EmotionsManager {
    
    /// 根据更定的字符串查找表情对象
    ///
    /// - Parameter string: eg:[xxx]
    /// - Returns:表情对象
    func findEmotion(string: String?) -> Emotion? {
        guard let string = string else { return nil }
        
        //遍历表情包数组
        for package in emotionPackages {
            //再遍历包里的表情数组
            let result = package.emotions.filter({ (emoticon) -> Bool in
                guard let chs = emoticon.chs else { return false }
                return chs == string
            })
            
            if result.count > 0 {
                return result[0]
            }
        }
        return nil
    }
    
    /// 将指定字符串转换成属性字符串
    ///
    /// - Parameter string:指定字符串
    /// - Parameter font:字体
    /// - Returns: 属性字符串
    func translateAttributeString(string: String?, font: UIFont) -> NSAttributedString {
        guard let string = string else { return NSAttributedString.init(string: "",attributes: [NSAttributedStringKey.font:font]) }
        
        //先统一设置通用属性
        let attrStr = NSMutableAttributedString(string: string, attributes: [NSAttributedStringKey.font:font])
        
        //查找所有匹配项
        let pattern = "\\[.*?\\]"
        guard let rgx = try? NSRegularExpression(pattern: pattern, options: []) else {
            return attrStr
        }
        
        //正则匹配
        let matches = rgx.matches(in: string, options: [], range: NSRange.init(location: 0, length: string.count))
        for match in matches.reversed() {
            let r = match.range
            let subString = (string as NSString).substring(with: r)
            //通过subString获取对应的表情模型，进而获取表情模型中图片属性字符串
            guard let emotion = findEmotion(string: subString),
                let imageAttrStr = emotion.imageAttributeString(font: font)
                else {
                    continue
            }
            
            //替换
            attrStr.replaceCharacters(in: r, with: imageAttrStr)
            
        }
        
        return attrStr
    }
}

// MARK: Emotion资源处理
extension EmotionsManager {
    /// 加载emoticons.plist文件信息
    func loadEmoticonsPlistFileInfo() -> Void {
        //拼接MQLEmotions.bundle全路径
        //创建MQLEmotions Bundle对象
        //拼接emoticons.plist全路径
        //获取emoticons.plist文件信息
        //NSArray数组转模型
        guard let emotionsBundleFullPath = Bundle.main.path(forResource: "MQLEmotions.bundle", ofType: nil),
                let emotionsBundle = Bundle(path: emotionsBundleFullPath),
                let emoticonsPlistFullPath = emotionsBundle.path(forResource: "emoticons.plist", ofType: nil),
                let array = NSArray.init(contentsOfFile: emoticonsPlistFullPath),
                let packages = NSArray.yy_modelArray(with: EmotionPackage.self, json: array) as? [EmotionPackage]
            else {
            return
        }
        
        emotionPackages = packages
    }
}











