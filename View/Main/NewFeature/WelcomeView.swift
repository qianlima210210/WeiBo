//
//  WelcomeView.swift
//  WeiBo
//
//  Created by QDHL on 2018/2/18.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

class WelcomeView: UIView {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var bottomConstraintOfView: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        var image: UIImage?
        if ThreeHalfInch {
            image = #imageLiteral(resourceName: "WelcomeBG")
        }else if FourInch {
            image = #imageLiteral(resourceName: "WelcomeBG_4")
        }else if FourSevenInch {
            image = #imageLiteral(resourceName: "WelcomeBG_4_7")
        }else if FiveFiveInch {
            image = #imageLiteral(resourceName: "WelcomeBG_5_5")
        }else if FiveEightInch {
            image = #imageLiteral(resourceName: "WelcomeBG_5_8")
        }else {
            
        }
        
        backgroundImageView.image = image
    }
    
    static func welcomeView() -> WelcomeView {
        let nib = UINib(nibName: "WelcomeView", bundle: nil)
        let v = nib.instantiate(withOwner: nil, options: nil)[0] as! WelcomeView
        v.frame = UIScreen.main.bounds
        return v
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        //更新自动布局：因为程序运行到didMoveToWindow时，自动布局的约束还未更新成坐标位置，所以需要使用layoutIfNeeded立即更新成坐标位置
        layoutIfNeeded()

        self.bottomConstraintOfView.constant = (kScreenHeight() - 120) / 2
        UIView.animate(withDuration: 3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: [], animations: {
            //更新自动布局
            self.layoutIfNeeded()
        }) { (_) in
            
        }
    }
    
}












