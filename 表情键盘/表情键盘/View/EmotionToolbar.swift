//
//  EmotionToolbar.swift
//  表情键盘
//
//  Created by QDHL on 2018/4/3.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit


/// 表情键盘底部工具栏
class EmotionToolbar: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //布局所有按钮
        let count = subviews.count
        let btnWidth = bounds.width / CGFloat(count)
        let btnHeight = bounds.height
        let rect = CGRect(x: 0, y: 0, width: btnWidth, height: btnHeight)
        
        for (i, btn) in subviews.enumerated() {
            btn.frame = rect.offsetBy(dx: CGFloat(i) * btnWidth, dy: 0.0)
        }
        
    }
}

private extension EmotionToolbar {
    func setupUI() {
        //1.获取表情管理器单例对象
        let manager = EmotionsManager.emotionsManager
        
        //2.获取表情包分组名
        for package in manager.emotionPackages {
            //1.实例化按钮对象
            let btn = UIButton(type: .custom)
            
            //2.设置按钮属性
            btn.setTitle(package.groupName, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            
            btn.setTitleColor(UIColor.white, for: .normal)
            btn.setTitleColor(UIColor.gray, for: .highlighted)
            btn.setTitleColor(UIColor.gray, for: .selected)
            
            //添加图片
            let imgName = "compose_emotion_table_\(package.bgImageName ?? "")_normal"
            let imgNameHL = "compose_emotion_table_\(package.bgImageName ?? "")_selected"
            let image = UIImage(named: imgName, in: manager.bundle, compatibleWith: nil)
            let imageHL = UIImage(named: imgNameHL, in: manager.bundle, compatibleWith: nil)
            
            let size = image?.size ?? CGSize()
            let insets = UIEdgeInsets(top: size.height / 2.0,
                                      left: size.width / 2.0,
                                      bottom: size.height / 2.0,
                                      right: size.width / 2.0)
            let newImage = image?.resizableImage(withCapInsets: insets)
            let newImageHL = imageHL?.resizableImage(withCapInsets: insets)
            
            btn.setBackgroundImage(newImage, for: .normal)
            btn.setBackgroundImage(newImageHL, for: .highlighted)
            btn.setBackgroundImage(newImageHL, for: .selected)
            
            btn.sizeToFit()
            
            //4.添加按钮
            addSubview(btn)
        }
        
    }
}


