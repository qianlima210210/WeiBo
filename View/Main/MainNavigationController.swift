//
//  MainNavigationController.swift
//  WeiBo
//
//  Created by QDHL on 2018/1/8.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationBar.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// 1. hidesBottomBarWhenPushed
    /// 2. 设置leftBarButtonItem
    /// - Parameters:
    ///   - viewController: 被设置的视图控制器
    ///   - animated: 是否弹出动画
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if viewControllers.count > 0 {
            
            viewController.hidesBottomBarWhenPushed = true
            
            if let viewController = viewController as? BaseViewController {
                var title = "返回"
                if viewControllers.count == 1 {
                    title = topViewController?.title ?? "返回"
                }
                
                viewController.newNavigationItem.leftBarButtonItem = UIBarButtonItem(title: title, target: self, action: #selector(backBtnClicked(sender:)), isBack: true)
            }
        }
        
        super.pushViewController(viewController, animated: animated)
    }
    
    @objc func backBtnClicked(sender: UIBarButtonItem) -> Void {
        popViewController(animated: true)
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
