//
//  TitleButton.swift
//  WeiBo
//
//  Created by QDHL on 2018/2/17.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

class TitleButton: UIButton {

    
    /// 重载构造函数
    ///
    /// - Parameter title: 如果是nil，就显示‘首页’
    /// - 如果不是nil，显示title和箭头图像
    init(title: String?) {
        super.init(frame: CGRect())
        
        //1>判断title是否为nil
        if title == nil {
            setTitle("首页", for: .normal)
        }else{
            setTitle(title!, for: .normal)
            //设置图像
            setImage(#imageLiteral(resourceName: "common_icon_arrowdown"), for: .normal)
            setImage(#imageLiteral(resourceName: "common_icon_arrowup"), for: .selected)
        }
        
        //2>设置字体和颜色
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        setTitleColor(UIColor.darkGray, for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
}


















