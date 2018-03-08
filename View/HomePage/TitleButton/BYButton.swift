//
//  BYButton.swift
//  Demo0308
//
//  Created by QDHL on 2018/3/8.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

class BYButton: UIButton {
    
    /// 是否调整标签及图片的位置
    var isAdjustTitleLabelAndImageView: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        adjustTitleLabelAndImageView()
    }
    
    
    /// 调整titleLabel、imageView的位置
    private func adjustTitleLabelAndImageView() {
        if !isAdjustTitleLabelAndImageView {
            return
        }
        
        guard let titleLabel = titleLabel,
                let imageView = imageView else {
            return
        }
        
        //当前位置
        let frameOfTitleLabel = titleLabel.frame
        let frameOfImageView = imageView.frame
        let middleMargin = CGFloat(0.0)
        let leftMargin = (bounds.width - frameOfTitleLabel.width - middleMargin - frameOfImageView.width) / 2
        
        //开始调整位置
        let newFrameOfTitleLabel =  CGRect(x: leftMargin,
                                            y: frameOfTitleLabel.minY,
                                            width: frameOfTitleLabel.width,
                                            height: frameOfTitleLabel.height)
        
        let newFrameOfImageView = CGRect(x: newFrameOfTitleLabel.maxX + middleMargin,
                                         y: frameOfImageView.minY,
                                         width: frameOfImageView.width,
                                         height: frameOfImageView.height)
        
        titleLabel.frame = newFrameOfTitleLabel
        imageView.frame = newFrameOfImageView
        
    }
    
}
