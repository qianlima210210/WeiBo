//
//  EmotionLayout.swift
//  表情键盘
//
//  Created by QDHL on 2018/4/3.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit


/// 表情集合视图的布局
class EmotionLayout: UICollectionViewFlowLayout {

    override func prepare() {
        super.prepare()
        //设定滚动方向:水平方向滚动，cell垂直方向布局；垂直方向滚动，cell水平方向布局
        scrollDirection = .horizontal
        
        //此处collectionView的实际大小已确定
        guard let collectionView = collectionView else { return }
        
        itemSize = collectionView.bounds.size
    }
}
