//
//  TabBar.swift
//  WeiBo
//
//  Created by QDHL on 2018/1/9.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

class TabBar: UITabBar {

    var btnClickCallback:((Int) ->Void)?
    var btnsBackgroundView = UIView()
    
    var homepageBtn = UIButton()
    var msgBtn = UIButton()
    var centerBtn = UIButton()
    var discoveryBtn = UIButton()
    var myBtn = UIButton()
    
    var selectedBtn: UIButton?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //去掉自带的灰色背景
        backgroundImage = UIImage()
        
        //去掉边框
        //shadowImage = UIImage()
        
        //添加按钮背景
        btnsBackgroundView.backgroundColor = UIColor.white
        addSubview(btnsBackgroundView)
        
        //添加按钮
        addBtns()
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
    func addBtns() -> Void {
        
        //添加首页按钮
        homepageBtn.tag = 1
        homepageBtn.setImage(#imageLiteral(resourceName: "tabbar_icon_home_normal"), for: .normal)
        homepageBtn.setImage(#imageLiteral(resourceName: "tabbar_icon_home_pressed"), for: .highlighted)
        homepageBtn.setImage(#imageLiteral(resourceName: "tabbar_icon_home_pressed"), for: .selected)
        homepageBtn.contentMode = .center
        homepageBtn.addTarget(self, action: #selector(btnClick(sender:)), for: .touchUpInside)
        btnsBackgroundView.addSubview(homepageBtn)
        
        //添加消息按钮
        msgBtn.tag = 2
        msgBtn.setImage(#imageLiteral(resourceName: "tabbar_icon_msg_normal"), for: .normal)
        msgBtn.setImage(#imageLiteral(resourceName: "tabbar_icon_msg_pressed"), for: .selected)
        msgBtn.setImage(#imageLiteral(resourceName: "tabbar_icon_msg_pressed"), for: .highlighted)
        msgBtn.addTarget(self, action: #selector(btnClick(sender:)), for: .touchUpInside)
        btnsBackgroundView.addSubview(msgBtn)
        
        //添加中间按钮
        centerBtn.tag = 3
        centerBtn.setImage(#imageLiteral(resourceName: "tabbar_middle_normal"), for: .normal)
        centerBtn.setImage(#imageLiteral(resourceName: "tabbar_middle_normal"), for: .selected)
        centerBtn.setImage(#imageLiteral(resourceName: "tabbar_middle_normal"), for: .highlighted)
        centerBtn.bounds.size = #imageLiteral(resourceName: "tabbar_middle_normal").size
        centerBtn.addTarget(self, action: #selector(btnClick(sender:)), for: .touchUpInside)
        btnsBackgroundView.addSubview(centerBtn)
        
        //添加发现按钮
        discoveryBtn.tag = 4
        discoveryBtn.setImage(#imageLiteral(resourceName: "tabbar_icon_discovery_normal"), for: .normal)
        discoveryBtn.setImage(#imageLiteral(resourceName: "tabbar_icon_discovery_pressed"), for: .selected)
        discoveryBtn.setImage(#imageLiteral(resourceName: "tabbar_icon_discovery_pressed"), for: .highlighted)
        discoveryBtn.addTarget(self, action: #selector(btnClick(sender:)), for: .touchUpInside)
        btnsBackgroundView.addSubview(discoveryBtn)
        
        //添加我的按钮
        myBtn.tag = 5
        myBtn.setImage(#imageLiteral(resourceName: "tabbar_icon_my_normal"), for: .normal)
        myBtn.setImage(#imageLiteral(resourceName: "tabbar_icon_my_pressed"), for: .selected)
        myBtn.setImage(#imageLiteral(resourceName: "tabbar_icon_my_pressed"), for: .highlighted)
        myBtn.addTarget(self, action: #selector(btnClick(sender:)), for: .touchUpInside)
        btnsBackgroundView.addSubview(myBtn)
        
        //设置默认选中按钮
        homepageBtn.isSelected = true
        selectedBtn = homepageBtn
    }
    
    @objc func btnClick(sender: UIButton) -> Void {
        
        if let selectedBtn = selectedBtn, sender.tag != 3 {
            
            if selectedBtn == sender {
                return
            }else{
                selectedBtn.isSelected = false
                sender.isSelected = true
                self.selectedBtn = sender
                
            }
        }
        
        if let btnClickCallback = btnClickCallback {
            btnClickCallback(sender.tag)
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bringSubview(toFront: btnsBackgroundView)
        btnsBackgroundView.frame = bounds
        
        //中间按钮位置
        if FiveEightInch {
            let offset = (centerBtn.bounds.height - kBYTabBarHeight + kBottomSafeAreaHeight) / CGFloat(2)
            centerBtn.center = CGPoint(x: bounds.width / CGFloat(2), y: (bounds.height - kBottomSafeAreaHeight) / CGFloat(2) - offset)
        }else{
            let offset = (centerBtn.bounds.height - kBYTabBarHeight) / CGFloat(2)
            centerBtn.center = CGPoint(x: bounds.width / CGFloat(2), y: bounds.height / CGFloat(2) - offset)
        }
        
        //依次调整其他按钮位置
        let widthOfCenter = centerBtn.bounds.width
        let btnWidth = (bounds.width - centerBtn.bounds.width) / CGFloat(4)
        var btnHeight: CGFloat = bounds.height
        if FiveEightInch {
            btnHeight  = btnHeight - kBottomSafeAreaHeight
        }
        
        homepageBtn.frame = CGRect(x: 0.0, y: 0.0, width: btnWidth, height: btnHeight)
        
        msgBtn.frame = CGRect(x: btnWidth, y: 0.0, width: btnWidth, height: btnHeight)
        
        discoveryBtn.frame = CGRect(x: btnWidth * 2 + widthOfCenter, y: 0.0, width: btnWidth, height: btnHeight)
        
        myBtn.frame = CGRect(x: btnWidth * 3 + widthOfCenter, y: 0.0, width: btnWidth, height: btnHeight)
    }
    
    
    func setBtnClickCallback(callback: @escaping (Int) ->Void) -> Void {
        btnClickCallback = callback
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        //将当前tabbar的触摸点转换坐标系，转换到中间按钮的身上，生成一个新的点
        let newPoint = convert(point, to: centerBtn)
        
        //判断如果这个新的点是在中间按钮身上，那么处理点击事件最合适的view就是中间按钮
        if centerBtn.point(inside: newPoint, with: event){
            return centerBtn
        }
        
        return super.hitTest(point, with: event)
    }
    
    
    
    
    
    
    
    
    
}
