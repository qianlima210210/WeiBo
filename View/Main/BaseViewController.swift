//
//  BaseViewController.swift
//  WeiBo
//
//  Created by QDHL on 2018/1/8.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    //新导航栏背景，将来会上下移动
    var newNavigationBarBackgroundView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: kScreenWidth, height: kStatusBarHeight + kNavigationBarHeight))
    //新导航栏
    var newNavigationBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0.0, y: kStatusBarHeight, width: kScreenWidth, height: kNavigationBarHeight))
    
    //新导航项
    var newNavigationItem: UINavigationItem = UINavigationItem()
    
    //重写标题
    override var title: String?{
        didSet{
            newNavigationItem.title = title
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUI()
    }
    
    func setUI() -> Void {
        view.backgroundColor = .white
        addNewNavigationBar()
    }
    
    
    /// 添加新导航栏
    func addNewNavigationBar() -> Void {
        //添加导航背景
        newNavigationBarBackgroundView.backgroundColor = UIColor.white
        view.addSubview(newNavigationBarBackgroundView)
        
        //去掉自带的灰色背景
        newNavigationBar.barTintColor = UIColor.white
        //去掉边框
        //newNavigationBar.shadowImage = UIImage()
        
        //设置导航标题属性
        newNavigationBar.titleTextAttributes = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18),
                                                NSAttributedStringKey.foregroundColor : UIColor.black]
        
        newNavigationBar.items = [newNavigationItem]
        newNavigationBarBackgroundView.addSubview(newNavigationBar)
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
