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
    
    let reusableCellID = "reusableCellID"
    
    /// 工厂方法
    ///
    /// - Returns: 表情输入视图对象
    class func emotionInputView() -> EmotionInputView {
        let nib = UINib(nibName: "EmotionInputView", bundle: nil)
        let view = nib.instantiate(withOwner: nil, options: nil)[0] as! EmotionInputView
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        let nib = UINib(nibName: "EmotionCell", bundle: nil)
//        collectionView.register(nib, forCellWithReuseIdentifier: reusableCellID)
        collectionView.register(EmotionCell.self, forCellWithReuseIdentifier: reusableCellID)
    }

}

extension EmotionInputView : UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return EmotionsManager.emotionsManager.emotionPackages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return EmotionsManager.emotionsManager.emotionPackages[section].numOfPage
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reusableCellID, for: indexPath) as! EmotionCell
        
        cell.emotions = EmotionsManager.emotionsManager.emotionPackages[indexPath.section].emotions(page: indexPath.item)
        
        return cell
    }
}










