//
//  BaseViewController.swift
//  WeiBo
//
//  Created by QDHL on 2018/1/8.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    var newNavigationBarBackgroundView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: kScreenWidth, height: kStatusBarHeight + kNavigationBarHeight))
    var newNavigationBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0.0, y: kStatusBarHeight, width: kScreenWidth, height: kNavigationBarHeight))
    var newNavigationItem: UINavigationItem = UINavigationItem()
    
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
    
    func addNewNavigationBar() -> Void {
        //添加导航背景
        newNavigationBarBackgroundView.backgroundColor = UIColor.orange
        view.addSubview(newNavigationBarBackgroundView)
        
        //去掉自带的灰色背景
        newNavigationBar.barTintColor = UIColor.orange
        //去掉边框
        newNavigationBar.shadowImage = UIImage()
        
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
