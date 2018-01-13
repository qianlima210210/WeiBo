//
//  BaseViewController.swift
//  WeiBo
//
//  Created by QDHL on 2018/1/8.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    //新导航条背景
    var newNavigationBarBackgroundView = UIView()
    //新导航条
    var newNavigationBar = UIView()
    
    //在设备旋转时，新导航条和新导航条背景之间需要修改的约束(NNB_NNBBV是newNavigationBar和newNavigationBarBackgroundView的首拼缩写)
    var topConstraint_NNB_NNBBV = NSLayoutConstraint()
    var heightConstraint_NNB_NNBBV = NSLayoutConstraint()
    
    //在设备旋转时，新导航条背景和试图控制器视图之间需要修改的约束(NNBBV_V是newNavigationBarBackgroundView和view的首拼缩写)
    var heightConstraint_NNBBV_V = NSLayoutConstraint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUI()
    }
    
    func setUI() -> Void {
        view.backgroundColor = .white
        addNewNavigationBar()
    }
    
    
    //MARK: 添加新导航栏
    func addNewNavigationBar() -> Void {
        newNavigationBarBackgroundView.backgroundColor = UIColor.orange
        newNavigationBar.backgroundColor = .red
        
        //为newNavigationBar及其父视图newNavigationBarBackgroundView添加约束
        newNavigationBar.translatesAutoresizingMaskIntoConstraints = false
        newNavigationBarBackgroundView.addSubview(newNavigationBar)
        //后续需要修改的约束，定义成var；不需要修改的定义成let
        let leftConstraint_NNB_NNBBV = NSLayoutConstraint(item: newNavigationBar, attribute: .left, relatedBy: .equal, toItem: newNavigationBarBackgroundView, attribute: .left, multiplier: 1.0, constant: 0.0)
        topConstraint_NNB_NNBBV = NSLayoutConstraint(item: newNavigationBar, attribute: .top, relatedBy: .equal, toItem: newNavigationBarBackgroundView, attribute: .top, multiplier: 1.0, constant: kStatusBarHeight())
        let widthConstraint_NNB_NNBBV = NSLayoutConstraint(item: newNavigationBar, attribute: .width, relatedBy: .equal, toItem: newNavigationBarBackgroundView, attribute: .width, multiplier: 1.0, constant: 0.0)
        heightConstraint_NNB_NNBBV = NSLayoutConstraint(item: newNavigationBar, attribute: .height, relatedBy: .equal, toItem: newNavigationBarBackgroundView, attribute: .height, multiplier: 1.0, constant: -kStatusBarHeight())
        
        newNavigationBarBackgroundView.addConstraints([leftConstraint_NNB_NNBBV, topConstraint_NNB_NNBBV, widthConstraint_NNB_NNBBV, heightConstraint_NNB_NNBBV])
        
        //为newNavigationBarBackgroundView及其父视图view添加约束
        newNavigationBarBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newNavigationBarBackgroundView)
        //后续需要修改的约束，定义成var；不需要修改的定义成let
        let leftConstraint_NNBBV_V = NSLayoutConstraint(item: newNavigationBarBackgroundView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0.0)
        let topConstraint_NNBBV_V = NSLayoutConstraint(item: newNavigationBarBackgroundView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0)
        let widthConstraint_NNBBV_V = NSLayoutConstraint(item: newNavigationBarBackgroundView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0.0)
        
        heightConstraint_NNBBV_V = NSLayoutConstraint(item: newNavigationBarBackgroundView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: kStatusBarHeight() + kNavigationBarHeight())
        
        view.addConstraints([leftConstraint_NNBBV_V, topConstraint_NNBBV_V, widthConstraint_NNBBV_V])
        newNavigationBarBackgroundView.addConstraints([heightConstraint_NNBBV_V])
        
    }

    //屏幕旋转时调整
    override func viewWillLayoutSubviews() {
        topConstraint_NNB_NNBBV.constant = kStatusBarHeight()
        heightConstraint_NNB_NNBBV.constant = -kStatusBarHeight()
        
        heightConstraint_NNBBV_V.constant = kStatusBarHeight() + kNavigationBarHeight()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}


