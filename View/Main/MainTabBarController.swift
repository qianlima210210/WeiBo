//
//  MainTabBarController.swift
//  WeiBo
//
//  Created by QDHL on 2018/1/8.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    let new_tabBar = TabBar()
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        replaceSystemTabBar()

        //启动定时器
        startTimer()

    }

    
    /// 替换系统tabBar
    func replaceSystemTabBar() -> Void {
        //用KVC将自己的tabbar和系统的tabBar替换下
        new_tabBar.setBtnClickCallback { (index: Int) in
            print("index: \(index)")
            if index != 3 {
                self.selectedIndex = index - 1
            }
        }
        
        //KVC实质是修改了系统的_tabBar
        self.setValue(new_tabBar, forKey: "tabBar")
        
        //设置tabBar盛放的视图控制器
        self.setViewControllers()
    }
    
    /// 设置tabBar盛放的视图控制器
    func setViewControllers() -> Void {
        let homePageVC = HomePageViewController()
        homePageVC.noteInfoDictionary = ["image": #imageLiteral(resourceName: "visitorView_blank_house"), "noteText": "欢迎使用博客，写点有意思的东西看，关注你所感兴趣得东西。赶紧注册登录吧！"]
        let homePageNav = MainNavigationController(rootViewController: homePageVC)
        
        let msgVC = MessageViewController()
        msgVC.noteInfoDictionary = ["image": #imageLiteral(resourceName: "visitorView_blank_msg"), "noteText": "欢迎使用博客，关注你所感兴趣的人，查找你感兴趣的消息。赶紧注册登录吧！"]
        let msgNav = MainNavigationController(rootViewController: msgVC)
        
        let middleVC = BaseViewController()
        let middleNav = MainNavigationController(rootViewController: middleVC)
        
        let discoveryVC = DiscoveryViewController()
        discoveryVC.noteInfoDictionary = ["image": #imageLiteral(resourceName: "visitorView_blank_default"), "noteText": "欢迎使用博客，发现你所感兴趣的人，查找你感兴趣的消息。赶紧注册登录吧！"]
        let discoveryNav = MainNavigationController(rootViewController: discoveryVC)
        
        let profileVC = ProfileViewController()
        profileVC.noteInfoDictionary = ["image": #imageLiteral(resourceName: "visitorView_blank_default"), "noteText": "欢迎使用博客，写点有意思的东西看，关注你所感兴趣得东西。赶紧注册登录吧！"]
        let profileNav = MainNavigationController(rootViewController: profileVC)
        
        let controllers = [homePageNav, msgNav, middleNav, discoveryNav, profileNav]
        viewControllers = controllers
        
    }
    
    ///启动定时器
    func startTimer() -> Void {
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(onTimer), userInfo: nil, repeats: true)
    }
    
    @objc func onTimer() -> Void {
        HttpEngine.httpEngine.getUnread_count { (count, error) in
            if error == nil {
                print("未读数：\(count ?? 0)")
                self.new_tabBar.setBadgeForHomepageBtn(count: count ?? 0)
            }else{
                print(error.debugDescription)
            }
        }
    }
    
    func cancelTimer() -> Void {
        timer?.invalidate()
        timer = nil
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .portrait
    }
    
    deinit {
        cancelTimer()
    }
}
