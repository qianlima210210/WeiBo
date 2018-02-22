//
//  WelcomeView.swift
//  WeiBo
//
//  Created by QDHL on 2018/2/18.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit
import SDWebImage

class WelcomeView: UIView {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var bottomConstraintOfView: NSLayoutConstraint!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var noteLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //程序运行到此，控件引用还未生效
    }
    
    
    /// xib或者storyboard加载完毕就会调用,设置初始值
    override func awakeFromNib() {
        super.awakeFromNib()
        //程序运行到此，控件引用已生效
        
        //1.设置背景图
        var backgroundImage: UIImage?
        if ThreeHalfInch {
            backgroundImage = #imageLiteral(resourceName: "WelcomeBG")
        }else if FourInch {
            backgroundImage = #imageLiteral(resourceName: "WelcomeBG_4")
        }else if FourSevenInch {
            backgroundImage = #imageLiteral(resourceName: "WelcomeBG_4_7")
        }else if FiveFiveInch {
            backgroundImage = #imageLiteral(resourceName: "WelcomeBG_5_5")
        }else if FiveEightInch {
            backgroundImage = #imageLiteral(resourceName: "WelcomeBG_5_8")
        }else {
            
        }
        
        backgroundImageView.image = backgroundImage
        
        //2.1设置头像地址和占位图
        guard let avatar_large = UserAccount.userAccount.avatar_large,
            let url = URL(string: avatar_large) else{
            return
        }
        
        avatarImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "avatar_large_userhead"), options: []) { (_, _, _, _) in
            
        }
        //2.1设置头像圆角
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
        avatarImageView.layer.masksToBounds = true
    }
    
    class func welcomeView() -> WelcomeView {
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
        UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: [], animations: {
            //更新自动布局
            self.layoutIfNeeded()
        }) { (_) in
            
            UIView.animate(withDuration: 0.5, animations: {
                self.noteLabel.alpha = 1.0
            }, completion: { (_) in
                self.removeFromSuperview()
            })
        }
    }
    
}












