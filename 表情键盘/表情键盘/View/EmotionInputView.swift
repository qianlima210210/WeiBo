//
//  EmotionInputView.swift
//  表情键盘
//
//  Created by QDHL on 2018/4/3.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

class EmotionInputView: UIView {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var toolbar: EmotionToolbar!
    
    /// 工厂方法
    ///
    /// - Returns: 表情输入视图对象
    class func emotionInputView() -> EmotionInputView {
        let nib = UINib(nibName: "EmotionInputView", bundle: nil)
        let view = nib.instantiate(withOwner: nil, options: nil)[0] as! EmotionInputView
        return view
    }

}
