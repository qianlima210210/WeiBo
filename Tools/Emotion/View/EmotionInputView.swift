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
    
    // 表情按钮点击回调
    var emotionBtnClickedBlock:((Emotion?) ->(Void))?
    
    let reusableCellID = "reusableCellID"
    
    /// 工厂方法
    ///
    /// - Returns: 表情输入视图对象
    class func emotionInputView(emotionBtnClicked:@escaping (Emotion?) ->(Void)) -> EmotionInputView {
        let nib = UINib(nibName: "EmotionInputView", bundle: nil)
        let view = nib.instantiate(withOwner: nil, options: nil)[0] as! EmotionInputView
        view.emotionBtnClickedBlock = emotionBtnClicked
        
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //注册cell
        collectionView.register(EmotionCell.self, forCellWithReuseIdentifier: reusableCellID)
    }

}

// MARK: - UICollectionViewDataSource协议实现
extension EmotionInputView : UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        //返回表情包个数，即表情分组个数
        return EmotionsManager.emotionsManager.emotionPackages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //某表情包需要使用多少页显示表情
        return EmotionsManager.emotionsManager.emotionPackages[section].numOfPage
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reusableCellID, for: indexPath) as! EmotionCell
        cell.emotions = EmotionsManager.emotionsManager.emotionPackages[indexPath.section].emotions(page: indexPath.item)
        cell.delegate = self
        
        return cell
    }
}

extension EmotionInputView : EmotionCellEmotionBtnClickedDelegate {
    func emotionBtnClicked(cell: EmotionCell, emotion: Emotion?) {
        emotionBtnClickedBlock?(emotion)
    }
}








