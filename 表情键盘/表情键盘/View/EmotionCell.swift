//
//  EmotionCell.swift
//  表情键盘
//
//  Created by QDHL on 2018/4/3.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit


/// 表情的页面cell
/// 每一个cell和collectionView的大小一样
/// 每一个cell用九宫格算法，添加20个表情
/// 最后一个位置放置删除按钮
class EmotionCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
    
    //该cell中包含的表情数组
    var emotions: [Emotion]? {
        didSet{
            //隐藏所有按钮
            for v in contentView.subviews {
                v.isHidden = true
            }
            
            //遍历表情模型数组，设置按钮图片
            for (i, emotion) in (emotions ?? []).enumerated() {
                if let btn = contentView.subviews[i] as? UIButton {
                    btn.setImage(emotion.image, for: .normal)
                    btn.isHidden = false
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EmotionCell {
    func setupUI() {
        let rowCount = 3
        let colCount = 7
        
        let leftMargin: CGFloat = 8.0
        let bottomMargin: CGFloat = 16.0
        
        let btnWidth = (bounds.width - leftMargin * CGFloat(2)) / CGFloat(colCount)
        let btnHeight = (bounds.height - bottomMargin) / CGFloat(rowCount)
        
        //1.连续创建21个按钮
        for i in 0..<21 {
            let row = i / colCount
            let col = i % colCount
            
            let btn = UIButton(type: .custom)
            btn.backgroundColor = .red
            let x = leftMargin + btnWidth * CGFloat(col)
            let y = btnHeight * CGFloat(row)
            
            btn.frame = CGRect(x: x, y: y, width: btnWidth, height: btnHeight)
            contentView.addSubview(btn)
            
        }
    }
}






