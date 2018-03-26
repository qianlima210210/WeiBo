//
//  MTRefreshView.swift
//  刷新控件001
//
//  Created by QDHL on 2018/3/26.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

class MTRefreshView: MQLRefreshView {

    @IBOutlet weak var buildingImageView: UIImageView!
    @IBOutlet weak var earthImageView: UIImageView!
    @IBOutlet weak var kangarooImageView: UIImageView!
    
    //父视图拖动高度，也就是父视图的高度
    override var parentViewHeight: CGFloat {
        didSet{
            if refreshState != .WillRefresh {
                kangarooImageViewHandler(parentViewHeight: parentViewHeight)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //处理建筑动画
        let building1 = #imageLiteral(resourceName: "icon_building_loading_1@2x.png")
        let building2 = #imageLiteral(resourceName: "icon_building_loading_2.png")
        buildingImageView.image = UIImage.animatedImage(with: [building1, building2], duration: 0.3)
        
        //处理地球动画
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.toValue = 0 - 2 * Double.pi
        animation.repeatCount = MAXFLOAT
        animation.duration = 3.0
        animation.isRemovedOnCompletion = false
        earthImageView.layer.add(animation, forKey: nil)
        
        //处理袋鼠动画
        //设置锚点
        kangarooImageView.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        
        //通过设置中心点，修改frame
        let x = self.bounds.width / 2.0
        let y = self.bounds.height - 23
        kangarooImageView.center = CGPoint(x: x, y: y)
        
        //缩放
        kangarooImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        
        let kangaroo1 = #imageLiteral(resourceName: "icon_small_kangaroo_loading_1@2x.png")
        let kangaroo2 = #imageLiteral(resourceName: "icon_small_kangaroo_loading_2@2x.png")
        kangarooImageView.image = UIImage.animatedImage(with: [kangaroo1, kangaroo2], duration: 0.3)
    }
    
    func kangarooImageViewHandler(parentViewHeight: CGFloat) -> Void {
        var scale: CGFloat = 0.0
        if parentViewHeight >=  (superview as! MQLRefreshControl).refreshOffset{
            scale = 1.0
        }else{
            scale = parentViewHeight / (superview as! MQLRefreshControl).refreshOffset
        }
        
        //缩放
        kangarooImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    
}
