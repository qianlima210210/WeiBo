//
//  AppDelegate.swift
//  WeiBo
//
//  Created by QDHL on 2018/1/8.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire

//import BYStatistics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //1-1、创建窗口，设置其白色背景
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        
        //1-2、创建根视图控制器，将其作为窗口的根视图控制器
        let mainTabBarController = MainTabBarController()
        window?.rootViewController = mainTabBarController
        
        //1-3、设置主窗口、显示
        window?.makeKeyAndVisible()
        
        //2-1添加统计
//        BYStat.setDebugEnabled(true)
//        BYStat.start(withAppkey: "maqianli", channel: "AppStore")
        
        setAdditions()
        
        return true
    }

}

extension AppDelegate {
    func setAdditions() -> Void {
        //1.设置SVProgressHUD最小移除时间
        SVProgressHUD.setMinimumDismissTimeInterval(1.0)
    }
    
}

