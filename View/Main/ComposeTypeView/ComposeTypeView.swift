//
//  ComposeTypeView.swift
//  WeiBo
//
//  Created by QDHL on 2018/3/26.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit
import pop

class ComposeTypeView: UIView {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var closeBtnConstraint: NSLayoutConstraint!
    @IBOutlet weak var returnBtnConstraint: NSLayoutConstraint!
    @IBOutlet weak var returnBtn: UIButton!
    
    
    
    let buttonsInfo = [["imageName":"tabbar_compose_idea", "title":"文字", "clsName":"ComposeViewController"],
                       ["imageName":"tabbar_compose_photo", "title":"照片/视频"],
                       ["imageName":"tabbar_compose_weibo", "title":"长微博"],
                       ["imageName":"tabbar_compose_lbs", "title":"签到"],
                       ["imageName":"tabbar_compose_review", "title":"点评"],
                       ["imageName":"tabbar_compose_more", "title":"更多", "actionName":"clickMore"],
                       ["imageName":"tabbar_compose_friend", "title":"好友圈"],
                       ["imageName":"tabbar_compose_wbcamera", "title":"微博相机"],
                       ["imageName":"tabbar_compose_music", "title":"音乐"],
                       ["imageName":"tabbar_compose_shooting", "title":"拍照"]]
    
    /// 从nib中加载ComposeTypeView对象
    class func initComposeTypeViewFromNib() ->  ComposeTypeView{
        let nib = UINib(nibName: "ComposeTypeView", bundle: nil)
        let view = nib.instantiate(withOwner: nil, options:nil)[0] as! ComposeTypeView
        view.alpha = 0.0
        return view
    }
    
    func show() -> Void {
        //将自己添加到应用窗口的根视图控制器上
        guard let vc = (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController else{
            return
        }
        
        vc.view.addSubview(self)
        
        //添加pop动效
        showCurrentView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //从nib加载的视图,执行到此，frame默认(0.0, 0.0, 600.0, 600.0)
        frame = UIScreen.main.bounds
        scrollView.contentSize = CGSize(width: scrollView.bounds.width * 2, height: scrollView.bounds.height)
        scrollView.isScrollEnabled = false
        
        addTypeButton()
    }
    
    @IBAction func closeBtnClicked(_ sender: UIButton) {
        hideButtons()
    }
    
    @IBAction func returnBtnClicked(_ sender: UIButton) {
        //将scrollView滚动到第1页
        let offset = CGPoint(x: 0.0, y: 0.0)
        scrollView.setContentOffset(offset, animated: true)
        
        let margin = CGFloat(0.0)
        closeBtnConstraint.constant = margin
        returnBtnConstraint.constant = margin

        UIView.animate(withDuration: 0.25, animations: {
            self.layoutIfNeeded()
            self.returnBtn.alpha = 0.0
        }) { _ in
            //隐藏返回按钮
            self.returnBtn.isHidden = true
            self.returnBtn.alpha = 1.0
        }
    }
}

extension ComposeTypeView {
    //添加类型按钮
    func addTypeButton() -> Void {

        var rect = bounds
        addButtonBGView(frame: rect, fromIdx: 0)
        rect = CGRect(x: rect.maxX, y: rect.minY, width: rect.width, height: rect.height)
        addButtonBGView(frame: rect, fromIdx: 6)
    }
    
    func addButtonBGView(frame: CGRect, fromIdx: Int) -> Void {
        //创建view
        let view = UIView()
        view.frame = frame
        
        //添加按钮
        addButtonOnView(view: view, idx: fromIdx)
        
        //添加view
        scrollView.addSubview(view)
    }
    
    func addButtonOnView(view: UIView, idx: Int) -> Void {
        let count = 6
        for i in idx ..< (idx + count) {
            if i >= buttonsInfo.count {
                break
            }
            
            let dic = buttonsInfo[i]
            guard let imageName = dic["imageName"],
                let title = dic["title"] else {
                    continue
            }
            
            //创建按钮
            let button = ComposeTypeButton.initComposeTypeButtonFromNib(imageName: imageName, text: title)
            button.clsName = dic["clsName"]
            
            //clickMore添加selecotor
            if let actionName = dic["actionName"] {
                button.addTarget(self, action: Selector(actionName), for: .touchUpInside)
            }else{
                button.addTarget(self, action: #selector(composeTypeBtnClicked(btn:)), for: .touchUpInside)
            }
            
            //添加按钮
            view.addSubview(button)
        }
        
        //对按钮布局
        let btnSize = CGSize(width: 100, height: 100)
        let margin = (view.bounds.width - btnSize.width * 3.0) / 4.0
        
        for (i, btn) in view.subviews.enumerated() {
            let x = CGFloat(i % 3 + 1) * margin + CGFloat(i % 3) * btnSize.width
            let y = (btnSize.height + CGFloat(24.0)) * CGFloat(i / 3)
            
            btn.frame = CGRect(x: x, y: y, width: btnSize.width, height: btnSize.height)
        }
    }
    
    @objc func composeTypeBtnClicked(btn: ComposeTypeButton) -> Void {
        guard let clsName = btn.clsName else { return }
        
        //拼接控制器名
        let classStringName = "ProductModelName.\(clsName)"
        //将控制名转换为类
        let classType = NSClassFromString(classStringName) as? UIViewController.Type
        if let type = classType {
            let newVC = type.init()
            print(newVC)
        }
    }
    
    @objc func clickMore() -> Void {
        print(#function)
        //将scrollView滚动到第二页
        let offset = CGPoint(x: scrollView.bounds.width, y: 0.0)
        scrollView.setContentOffset(offset, animated: true)
        
        //显示返回按钮
        returnBtn.isHidden = false
        
        let margin = scrollView.bounds.width / 6
        closeBtnConstraint.constant += margin
        returnBtnConstraint.constant -= margin
        
        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        }
    }
}

//MARK: pop动画扩展
extension ComposeTypeView {
    
    /// 依次隐藏按钮，最后在隐藏自己
    func hideButtons() -> Void {
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        let view = scrollView.subviews[page]
        
        for (i, btn) in view.subviews.enumerated().reversed() {
            let animation0  = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
            animation0?.fromValue = btn.layer.position.y
            animation0?.toValue = btn.layer.position.y + 300
            animation0?.beginTime = CACurrentMediaTime() + CFTimeInterval(view.subviews.count - 1 - i) * 0.01
            
            if i == 0 {
                animation0?.completionBlock = {(animation: POPAnimation?, finished:Bool) -> Void in
                    self.hideCurrentView()
                }
            }
            
            btn.layer.pop_add(animation0, forKey: nil)
        }
        
    }
    
    /// 隐藏自己
    func hideCurrentView() -> Void {
        //创建动画
        let animation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        animation?.fromValue = 1.0
        animation?.toValue = 0.0
        animation?.duration = 0.25
        
        animation?.completionBlock = {(_, _) -> Void in
            self.removeFromSuperview()
        }
        
        //将动画添加的视图
        pop_add(animation, forKey: nil)
    }
    
    func showCurrentView() -> Void {
        //创建动画
        let animation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        animation?.fromValue = 0.0
        animation?.toValue = 1.0
        animation?.duration = 0.25
        
        //将动画添加的视图
        pop_add(animation, forKey: nil)
        
        //让类型按钮以弹力效果显示
        showButton()
    }
    
    //让类型按钮以弹力效果显示
    func showButton() -> Void {
        //获取scrollview中的view0
        let view0 = scrollView.subviews[0]
        
        //遍历view0中的所有按钮
        for (i, btn) in view0.subviews.enumerated() {
            //创建动画
            let animation = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
            animation?.fromValue = btn.center.y + 200
            animation?.toValue = btn.center.y
            
            //弹力系数，取值[0, 20]，数值越大弹性越大，默认4
            animation?.springBounciness = 4
            
            //弹力速度，取值[0, 20]，数值越大弹性越大，默认12
            animation?.springSpeed = 6
            
            //设置动画启动时间点
            animation?.beginTime = CACurrentMediaTime() + CFTimeInterval(i) * 0.01
            
            //添加动画
            btn.layer.pop_add(animation, forKey: nil)
        }
    }
}









