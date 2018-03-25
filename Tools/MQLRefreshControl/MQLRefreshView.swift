//
//  MQLRefreshView.swift
//  刷新控件001
//
//  Created by QDHL on 2018/3/24.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

class MQLRefreshView: UIView {
    //箭头图像视图
    @IBOutlet weak var arrowheadImageView: UIImageView!
    //菊花指示器
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    //提示标签
    @IBOutlet weak var promptLabel: UILabel!
    
    //刷新状态
    /*
     IOS系统中UIView封装的旋转动画，默认是顺时针旋转，就近原则；要想实现逆方向旋转，需要调整一个非常小的数字（哪边近，就从哪变开始旋转）
     如果想实现360旋转，需要核心动画CABaseAnimation
    */
    var refreshState: RefreshState = .Normal {
        didSet{
            switch refreshState {
            case .Normal:
                //显示箭头
                arrowheadImageView.isHidden = false
                
                //隐藏菊花
                indicator.stopAnimating()
                
                promptLabel.text = "下拉刷新..."
                UIView.animate(withDuration: 0.25){
                    self.arrowheadImageView.transform = CGAffineTransform.identity
                }
            case .Pulling:
                promptLabel.text = "松手刷新..."
                UIView.animate(withDuration: 0.25){
                    self.arrowheadImageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi - 0.0001))
                }
            case .WillRefresh:
                promptLabel.text = "正在刷新..."
                
                //隐藏箭头
                arrowheadImageView.isHidden = true
                
                //显示菊花
                indicator.startAnimating()
                
            }
        }
    }
    
    //工厂方法，从nib中初始化MQLRefreshView对象
    class func initMQLRefreshViewFromNib() -> MQLRefreshView{
        let nib = UINib(nibName: "MQLRefreshView", bundle: nil)
        return nib.instantiate(withOwner: nil, options: nil)[0] as! MQLRefreshView
    }
    
    
}
