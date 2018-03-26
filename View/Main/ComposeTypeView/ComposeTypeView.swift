//
//  ComposeTypeView.swift
//  WeiBo
//
//  Created by QDHL on 2018/3/26.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

class ComposeTypeView: UIView {

    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        backgroundColor = UIColor.cyan
    }

    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
    func show() -> Void {
        //将自己添加到应用窗口的根视图控制器上
        guard let vc = (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController else{
            return
        }
        
        vc.view.addSubview(self)
    }
}
