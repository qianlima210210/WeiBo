//
//  WelcomeView.swift
//  WeiBo
//
//  Created by QDHL on 2018/2/18.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

class WelcomeView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.yellow
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
}
