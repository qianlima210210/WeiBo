//
//  NewFeatureView.swift
//  WeiBo
//
//  Created by QDHL on 2018/2/18.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

class NewFeatureView: UIView {
    
    @IBOutlet weak var scrollView: UIScrollView!
    var enterBtn = UIButton()
    
    class func newFeatureView() -> NewFeatureView {
        let nib = UINib(nibName: "NewFeatureView", bundle: nil)
        let v = nib.instantiate(withOwner: nil, options: nil)[0] as! NewFeatureView
        v.frame = UIScreen.main.bounds
        return v
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //如果使用autoLayout布局界面，运行到此，视图大小是600*600
        //添加4个引导图
        let count = 4
        let rect = kScreenFrame()
        
        for i in 0..<count {
            
            var imageName: String?
            if ThreeHalfInch {
                imageName = "s\(i+1)_3_5"
            }else if FourInch {
                imageName = "s\(i+1)_4"
            }else if FourSevenInch {
                imageName = "s\(i+1)_4_7"
            }else if FiveFiveInch {
                imageName = "s\(i+1)_5_5"
            }else if FiveEightInch {
                imageName = "s\(i+1)_5_8"
            }else {
                
            }
            
            if let image = UIImage.init(named: imageName ?? ""){
                let iv = UIImageView(image:image)
                //设置大小
                iv.frame = rect.offsetBy(dx: CGFloat(i) * kScreenWidth(), dy: 0.0)
                
                scrollView.addSubview(iv)
                
                if (i == (count - 1)) {
                    //添加进入按钮
                    addEnterBtn(imageView: iv)
                }
            }
        }
        
        //制定scrollView的属性
        scrollView.contentSize = CGSize(width: CGFloat(count + 1) * kScreenWidth(), height: 0.0)
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
    }
    
    //添加进入按钮
    func addEnterBtn(imageView: UIImageView) -> Void {
        imageView.isUserInteractionEnabled = true
        enterBtn.setTitle("进入微博", for: .normal)
        enterBtn.setTitleColor(UIColor.blue, for: .normal)
        enterBtn.addTarget(self, action: #selector(enterBtnClicked), for: .touchUpInside)
        
        enterBtn.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(enterBtn)
        
        let centerXConstraint = NSLayoutConstraint(item: enterBtn, attribute: .centerX, relatedBy: .equal, toItem: imageView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let bottomConstraint = NSLayoutConstraint(item: enterBtn, attribute: .bottom, relatedBy: .equal, toItem: imageView, attribute: .bottom, multiplier: 1.0, constant: -120)
        let widthConstraint = NSLayoutConstraint(item: enterBtn, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 80)
        let heightConstraint = NSLayoutConstraint(item: enterBtn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 30)
        
        imageView.addConstraints([centerXConstraint, bottomConstraint])
        enterBtn.addConstraints([widthConstraint, heightConstraint])
    }
    
    @objc func enterBtnClicked() -> Void {
        self.removeFromSuperview()
    }
    
}

extension NewFeatureView: UIScrollViewDelegate{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        //判断是否最后一页，是的话移除自己
        let page = Int(scrollView.contentOffset.x / kScreenWidth())
        if page == (scrollView.subviews.count) {
            self.removeFromSuperview()
        }
    }
}







