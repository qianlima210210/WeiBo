//
//  EmotionPackage.swift
//  Swift图文混排
//
//  Created by QDHL on 2018/3/30.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit
import YYModel

/// 表情包模型
@objcMembers class EmotionPackage: NSObject {
    
    /// 分组名
    var groupName: String?
    
    /// 背景图片名称
    var bgImageName: String?
    
    /// 表情包所在目录，从该目录下加载info.plist，获取表情模型数组
    var directory: String? {
        didSet{
            //拼接MQLEmotions.bundle全路径
            //创建MQLEmotions Bundle对象
            //拼接info.plist全路径
            //获取info.plist文件信息
            //NSArray数组转模型
            guard let directory = directory,
                let emotionsBundleFullPath = Bundle.main.path(forResource: "MQLEmotions.bundle", ofType: nil),
                let emotionsBundle = Bundle(path: emotionsBundleFullPath),
                let infoPlistFullPath = emotionsBundle.path(forResource: "info.plist", ofType: nil, inDirectory: directory),
                let array = NSArray.init(contentsOfFile: infoPlistFullPath),
                let itmes = NSArray.yy_modelArray(with: Emotion.self, json: array) as? [Emotion]
                else { return }
            
            emotions = itmes
            //遍历emotions，为每一项添加directory
            for item in emotions {
                item.directory = directory
            }
        }
    }
    
    /// 表情模型数组
    var emotions = [Emotion]()
    
    /// 此表情包所需页面
    var numOfPage: Int {
        return (emotions.count - 1) / 20 + 1
    }
    
    
    /// 从表情包中，按照page截取最多20个表情模型的数组
    ///
    /// - Parameter page: 页码
    /// - Returns:表情模型的数组
    func emotions(page: Int) -> [Emotion] {
        //每页的数量
        let count = 20
        let location = page * count
        var length = count
        
        //判断范围是否越界
        if location + length > emotions.count {
            length = emotions.count - location
        }
        let range = NSRange.init(location: location, length: length)
        let subArray = (emotions as NSArray).subarray(with: range)
        
        return subArray as! [Emotion]
    }
    
    override var description: String {
        return yy_modelDescription()
    }
}
