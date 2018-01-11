//
//  AppDelegate.swift
//  WeiBo
//
//  Created by QDHL on 2018/1/8.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //1、创建窗口，设置其白色背景
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        
        //2、创建根视图控制器，将其作为窗口的根视图控制器
        let mainTabBarController = MainTabBarController()
        window?.rootViewController = mainTabBarController
        
        //3、设置主窗口、显示
        window?.makeKeyAndVisible()
        
        return true
    }

}

