//
//  EmotionCell.swift
//  表情键盘
//
//  Created by QDHL on 2018/4/3.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

protocol EmotionCellEmotionBtnClickedDelegate : NSObjectProtocol {
    func emotionBtnClicked(cell: EmotionCell, emotion: Emotion?)
}

/// 表情的页面cell
/// 每一个cell和collectionView的大小一样
/// 每一个cell用九宫格算法，添加20个表情
/// 最后一个位置放置删除按钮
class EmotionCell: UICollectionViewCell {
    
    //该cell中包含的表情数组
    var emotions: [Emotion]? {
        didSet{
            //隐藏所有按钮
            for v in contentView.subviews {
                v.isHidden = true
            }
            
            //显示删除按钮
            contentView.subviews.last?.isHidden = false
            
            //遍历表情模型数组，设置按钮图片
            for (i, emotion) in (emotions ?? []).enumerated() {
                if let btn = contentView.subviews[i] as? UIButton {
                    btn.setImage(emotion.image, for: .normal)
                    btn.isHidden = false
                    
                    btn.setTitle(emotion.emojString, for: .normal)
                }
            }
        }
    }
    
    weak var delegate: EmotionCellEmotionBtnClickedDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 表情按钮点击相应函数
    ///
    /// - Parameter button: 被点击的按钮
    @objc func emotionBtnClicked(button: UIButton) -> Void {
        var emotion: Emotion?
        if button.tag < (emotions ?? []).count {
            emotion = emotions?[button.tag]
        }
        
        delegate?.emotionBtnClicked(cell: self, emotion: emotion)
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
        
        //1.连续创建21个按钮=20个表情+1删除
        for i in 0..<21 {
            let row = i / colCount
            let col = i % colCount
            
            let btn = UIButton(type: .custom)
            btn.tag = i
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 32)//32是表情图片的高度
            btn.addTarget(self, action: #selector(emotionBtnClicked(button:)), for: .touchUpInside)
            
            let x = leftMargin + btnWidth * CGFloat(col)
            let y = btnHeight * CGFloat(row)
            
            btn.frame = CGRect(x: x, y: y, width: btnWidth, height: btnHeight)
            contentView.addSubview(btn)
        }
        
        //设置删除按钮
        let removeBtn = contentView.subviews.last as! UIButton
        let image = UIImage(named: "compose_emotion_delete", in: EmotionsManager.emotionsManager.bundle, compatibleWith: nil)
        let imageHL = UIImage(named: "compose_emotion_delete_highlighted", in: EmotionsManager.emotionsManager.bundle, compatibleWith: nil)
        removeBtn.setImage(image, for: .normal)
        removeBtn.setImage(imageHL, for: .normal)
        
    }
}
















