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
    
    //导航标题栏frame: CGRect(x: 0, y: 0, width: kScreenWidth(), height: kNavigationBarHeight())
    var navigationTitleLab = UILabel()
    
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
    
    //MARK: 设置导航标题
    func setNavigationTitle(titlte: String) {
        
        navigationTitleLab.text = title
        navigationTitleLab.font = UIFont.boldSystemFont(ofSize: 17)
        navigationTitleLab.textColor = .white
        navigationTitleLab.textAlignment = .center
        
        //为navigationTitleLab及其父视图newNavigationBar添加约束
        navigationTitleLab.translatesAutoresizingMaskIntoConstraints = false
        newNavigationBar.addSubview(navigationTitleLab)
        
        let leftConstraint_NTL_NNB = NSLayoutConstraint(item: navigationTitleLab, attribute: .left, relatedBy: .equal, toItem: newNavigationBar, attribute: .left, multiplier: 1.0, constant: 0.0)
        let topConstraint_NTL_NNB = NSLayoutConstraint(item: navigationTitleLab, attribute: .top, relatedBy: .equal, toItem: newNavigationBar, attribute: .top, multiplier: 1.0, constant: 0.0)
        let widthConstraint_NTL_NNB = NSLayoutConstraint(item: navigationTitleLab, attribute: .width, relatedBy: .equal, toItem: newNavigationBar, attribute: .width, multiplier: 1.0, constant: 0.0)
        let heightConstraint_NTL_NNB = NSLayoutConstraint(item: navigationTitleLab, attribute: .height, relatedBy: .equal, toItem: newNavigationBar, attribute: .height, multiplier: 1.0, constant: 0.0)
        
        newNavigationBar.addConstraints([leftConstraint_NTL_NNB, topConstraint_NTL_NNB, widthConstraint_NTL_NNB, heightConstraint_NTL_NNB])
    }

    //MARK: 添加常规导航项：左边按钮，中间标题，右边按钮
    func addNoromalNavigationItems(leftImage: UIImage, leftTarget: Any?, leftAction: Selector,
                                   titlte: String,
                                   rightImage: UIImage, rightTarget: Any?, rightAction: Selector) -> Void {
        let leftMargin = 10.0
        let topMargin = 7.0
        
        let leftBtun = UIButton(frame: CGRect(x: leftMargin, y: topMargin, width: 30, height: 30))
        leftBtun.setImage(leftImage, for: .normal)
        leftBtun.addTarget(leftTarget, action: leftAction, for: .touchUpInside)
        newNavigationBar.addSubview(leftBtun)
        
        let titleLab = UILabel(frame: CGRect(x: 40, y: 0, width: kScreenWidth() - 40 * 2, height: kNavigationBarHeight()))
        titleLab.text = title
        titleLab.textColor = .white
        titleLab.textAlignment = .center
        newNavigationBar.addSubview(titleLab)
        
        let rightBtun = UIButton(frame: CGRect(x: Double(40.0 + titleLab.bounds.width), y: topMargin, width: 30.0, height: 30.0))
        rightBtun.setImage(rightImage, for: .normal)
        rightBtun.addTarget(rightTarget, action: rightAction, for: .touchUpInside)
        newNavigationBar.addSubview(rightBtun)
    }
    
    //MARK: 屏幕旋转时调整
    override func viewWillLayoutSubviews() {
        topConstraint_NNB_NNBBV.constant = kStatusBarHeight()
        heightConstraint_NNB_NNBBV.constant = -kStatusBarHeight()
        heightConstraint_NNBBV_V.constant = kStatusBarHeight() + kNavigationBarHeight()
        
        //navigationTitleLab.frame = CGRect(x: 0, y: 0, width: kScreenWidth(), height: kNavigationBarHeight())
        
    }
    
    //MARK: 指定状态栏风格
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
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


