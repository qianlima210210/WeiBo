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
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if viewControllers.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        }
        
        super.pushViewController(viewController, animated: animated)
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

//MARK: 设备旋转
extension MainNavigationController {
    override var shouldAutorotate: Bool {
        if let topViewController = self.topViewController {
            return topViewController.shouldAutorotate
        }else{
            return false
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        if let topViewController = self.topViewController {
            return topViewController.supportedInterfaceOrientations
        }else{
            return .portrait
        }
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        if let topViewController = self.topViewController {
            return topViewController.preferredInterfaceOrientationForPresentation
        }else{
            return .portrait
        }
    }
}

//MARK: 状态栏风格
extension MainNavigationController{
    override var childViewControllerForStatusBarStyle: UIViewController?{
        return self.topViewController?.childViewControllerForStatusBarStyle
    }
}
