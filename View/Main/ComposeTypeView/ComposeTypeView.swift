//
//  ComposeTypeView.swift
//  WeiBo
//
//  Created by QDHL on 2018/3/26.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

class ComposeTypeView: UIView {

    /// 从nib中加载ComposeTypeView对象
    class func initComposeTypeViewFromNib() ->  ComposeTypeView{
        let nib = UINib(nibName: "ComposeTypeView", bundle: nil)
        let view = nib.instantiate(withOwner: nil, options:nil)[0] as! ComposeTypeView
        return view
    }
    
    func show() -> Void {
        //将自己添加到应用窗口的根视图控制器上
        guard let vc = (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController else{
            return
        }
        
        vc.view.addSubview(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //从nib加载的视图,执行到此，frame默认(0.0, 0.0, 600.0, 600.0)
        frame = UIScreen.main.bounds
        
        addTypeButton()
    }
}

extension ComposeTypeView {
    //添加类型按钮
    func addTypeButton() -> Void {
        let button = ComposeTypeButton.initComposeTypeButtonFromNib(imageName: "tabbar_compose_idea", text: "文本")
        button.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
        self.addSubview(button);
        
        //添加自动布局约束
//        button.translatesAutoresizingMaskIntoConstraints = false
//        let top = NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0)
//        let left = NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0)
//
//        let width = NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: button.bounds.width)
//        let height = NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: button.bounds.height)
//
//        self.addConstraints([top, left])
//        button.addConstraints([width, height])
    }
    
    @objc func buttonClicked(sender: ComposeTypeButton) -> Void {
       print("buttonClicked")
    }
}









