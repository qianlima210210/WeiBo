//
//  MainTabBarController.swift
//  WeiBo
//
//  Created by QDHL on 2018/1/8.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //创建自己的tabbar，然后用KVC将自己的tabbar和系统的tabBar替换下
        let tabBar = TabBar()
        tabBar.setBtnClickCallback { (index: Int) in
            print("index: \(index)")
            if index != 3 {
                self.selectedIndex = index - 1
            }
        }
        
        //KVC实质是修改了系统的_tabBar
        self.setValue(tabBar, forKey: "tabBar")
        
        //设置tabBar盛放的视图控制器
        self.setViewControllers()
    }

    
    /// 设置tabBar盛放的视图控制器
    func setViewControllers() -> Void {
        let homePageVC = HomePageViewController()
        let homePageNav = MainNavigationController(rootViewController: homePageVC)
        
        let msgVC = MessageViewController()
        let msgNav = MainNavigationController(rootViewController: msgVC)
        
        let middleVC = BaseViewController()
        let middleNav = MainNavigationController(rootViewController: middleVC)
        
        let discoveryVC = DiscoveryViewController()
        let discoveryNav = MainNavigationController(rootViewController: discoveryVC)
        
        let profileVC = ProfileViewController()
        let profileNav = MainNavigationController(rootViewController: profileVC)
        
        let controllers = [homePageNav, msgNav, middleNav, discoveryNav, profileNav]
        viewControllers = controllers
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .portrait
    }
    
}
