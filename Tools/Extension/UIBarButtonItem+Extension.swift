//
//  UIBarButtonItem+Extension.swift
//  WeiBo
//
//  Created by QDHL on 2018/1/11.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    convenience init(title: String, target: Any?, action: Selector, isBack: Bool = false) {
        
        let button = UIButton()
        
        button.setTitle(title, for: .normal)
        button.setTitle(title, for: .highlighted)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitleColor(UIColor.orange, for: .highlighted)
        button.addTarget(target, action: action, for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
        if isBack {
            button.setImage(#imageLiteral(resourceName: "arrow_back_blue_highlighted"), for: .highlighted)
            button.setImage(#imageLiteral(resourceName: "arrow_back_blue_highlighted"), for: .normal)
            
            button.sizeToFit()
        }
        
        self.init(customView: button)
    }
}
