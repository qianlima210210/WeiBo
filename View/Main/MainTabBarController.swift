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
        
        /// 注册通知
        registerNotification()
    }

    /// 替换系统tabBar
    func replaceSystemTabBar() -> Void {
        //用KVC将自己的tabbar和系统的tabBar替换下
        new_tabBar.setBtnClickCallback { (index: Int, repeatClick: Bool) in
            print("index: \(index)")
            if repeatClick && index == 1 {
                //将首页内容滚动到顶部
                self.scrollTopOfHomePageContent()
                return
            }
            
            if index != 3 {
                self.selectedIndex = index - 1
            }
        }
        
        //KVC实质是修改了系统的_tabBar
        self.setValue(new_tabBar, forKey: "tabBar")
        
        //设置tabBar盛放的视图控制器
        self.setViewControllers()
        
        //设置新特性视图或欢迎视图
        setNewFeatureViewOrWelcomeView()
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
    
    deinit {
        cancelTimer()
        NotificationCenter.default.removeObserver(self)
    }
    
    //将首页内容滚动到顶部
    func scrollTopOfHomePageContent() -> Void {
        if let vc = ((self.selectedViewController as? MainNavigationController)?.childViewControllers[0]) as? BaseViewController {
            if vc.refreshCtl.isRefreshing == false{
                vc.tableView.contentOffset = CGPoint(x: 0, y: 0)
                vc.autoShowRefreshCtl()
            }
        }
    }
    
}

//MARK: 设备旋转
extension MainTabBarController {
    override var shouldAutorotate: Bool {
        if let selectedViewController = self.selectedViewController {
            return selectedViewController.shouldAutorotate
        }else{
            return false
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        if let selectedViewController = self.selectedViewController {
            return selectedViewController.supportedInterfaceOrientations
        }else{
            return .portrait
        }
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        if let selectedViewController = self.selectedViewController {
            return selectedViewController.preferredInterfaceOrientationForPresentation
        }else{
            return .portrait
        }
    }
}

//MARK: 状态栏风格
extension MainTabBarController{
    override var childViewControllerForStatusBarStyle: UIViewController?{
        return self.selectedViewController?.childViewControllerForStatusBarStyle
    }
}

//MARK: 通知
extension MainTabBarController{
    /// 注册通知
    func registerNotification() -> Void {
        NotificationCenter.default.addObserver(self, selector: #selector(receiveLogonNotification(no:)), name: NSNotification.Name(rawValue: logonNotification), object: nil)
    }
    
    @objc func receiveLogonNotification(no: Notification) -> Void {
        if let userInfo = no.userInfo as? [String:Any],
            let showAlert = userInfo["showAlert"] as? Bool{
            
            if showAlert {
                let alert = UIAlertController(title: "登录", message: "请求需要先登录，是否登录？", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "确认", style: .default, handler: { (alertAction) in
                    self.presentOAuthViewController()
                }))
                alert.addAction(UIAlertAction(title: "取消", style: .default, handler: { (alertAction) in
                    
                }))
                
                let selectVC = self.selectedViewController
                selectVC?.present(alert, animated: true, completion: {
                    
                })
                
            }
        }else{
            presentOAuthViewController()
        }
        
    }
    
    func presentOAuthViewController() -> Void {
        let selectVC = self.selectedViewController
        
        let vc = OAuthViewController()
        let nav = MainNavigationController(rootViewController: vc)
        
        selectVC?.present(nav, animated: true, completion: {
            
        })
    }
}


//MARK: 定时器
extension MainTabBarController{
    ///启动定时器
    func startTimer() -> Void {
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(onTimer), userInfo: nil, repeats: true)
    }
    
    @objc func onTimer() -> Void {
        if UserAccount.userAccount.isLogon == false {
            return
        }
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
}

extension MainTabBarController{
    //设置新特性视图或欢迎视图
    func setNewFeatureViewOrWelcomeView() -> Void {
        if UserAccount.userAccount.isLogon == false {
            return
        }
        
        let v = isNewFeature ? NewFeatureView() : WelcomeView()
        v.frame = view.bounds
        view .addSubview(v)
    }
    
    private var isNewFeature: Bool{
        return false
    }
}
