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
    
    //导航标题栏
    var navigationTitleLab = UILabel()
    
    //表格视图
    var tableView = UITableView()
    
    //刷新控件
    var refreshCtl = UIRefreshControl()
    var isPullDown = false
    var isPullUp = false
    
    //游客视图
    var visitorView = UIView()
    //游客提示信息
    var noteInfoDictionary:[String:Any]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        autoShowRefreshCtl()
    }
    
    //MARK: 设置界面
    func setUI() -> Void {
        view.backgroundColor = .white
        addNewNavigationBar()
        
        if HttpEngine.httpEngine.isLogon {
            addTableView()
        }else{
            addVisitorView()
        }
        
    }
    
    //MARK: 加载数据，基类只定义，子类去重写
    func loadData() -> Void {
        isPullDown = false
        isPullUp = false
        refreshCtl.endRefreshing()
    }
    
    //MARK: 屏幕旋转时调整
    override func viewWillLayoutSubviews() {
        topConstraint_NNB_NNBBV.constant = kStatusBarHeight()
        heightConstraint_NNB_NNBBV.constant = -kStatusBarHeight()
        heightConstraint_NNBBV_V.constant = kStatusBarHeight() + kNavigationBarHeight()
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

//MARK: BaseViewController分类：基于UI
extension BaseViewController{
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
    func setNavigationTitle(title: String) {
        
        navigationTitleLab.text = title
        navigationTitleLab.font = UIFont.boldSystemFont(ofSize: 20)
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
    
    //MARK: 添加表格视图
    func addTableView() -> Void {
        tableView.separatorStyle = .none
        
        tableView.dataSource = self
        tableView.delegate = self
        
        //为tableView及其父视图view添加约束
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        let leftConstraint_TV_V = NSLayoutConstraint(item: tableView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0.0)
        let topConstraint_TV_V = NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: newNavigationBarBackgroundView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        let widthConstraint_TV_V = NSLayoutConstraint(item: tableView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0.0)
        let bottomConstraint_TV_V = NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: -kTabBarHeight())
        
        view.addConstraints([leftConstraint_TV_V, topConstraint_TV_V, widthConstraint_TV_V, bottomConstraint_TV_V])
        
        //为tableView添加刷新控件
        tableView.addSubview(refreshCtl)
        refreshCtl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        
    }
    
    @objc func refresh(sender: UIRefreshControl) -> Void {
        if isPullUp {
            refreshCtl.endRefreshing()
            return
        }
        isPullDown = true
        loadData()
    }
    
    //自动显示刷新控件
    func autoShowRefreshCtl() -> Void {
        if (refreshCtl.isRefreshing == false && self.tableView.contentOffset.y == 0){
            UIView.animate(withDuration: 0.25, animations: {
                self.tableView.contentOffset = CGPoint(x: 0, y: -self.refreshCtl.bounds.height)
            }, completion: { (finished) in
                self.refreshCtl.beginRefreshing()
                self.refreshCtl.sendActions(for: UIControlEvents.valueChanged)
            })
        }
    }
    
    //MARK:添加游客视图
    func addVisitorView(){
        
        //为visitorView及其父视图view添加约束
        visitorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(visitorView)
        
        let leftConstraint_VV_V = NSLayoutConstraint(item: visitorView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0.0)
        let topConstraint_VV_V = NSLayoutConstraint(item: visitorView, attribute: .top, relatedBy: .equal, toItem: newNavigationBarBackgroundView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        let widthConstraint_VV_V = NSLayoutConstraint(item: visitorView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0.0)
        let bottomConstraint_VV_V = NSLayoutConstraint(item: visitorView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: -kTabBarHeight())
        
        view.addConstraints([leftConstraint_VV_V, topConstraint_VV_V, widthConstraint_VV_V, bottomConstraint_VV_V])
        
        //添加游客视图上的内容视图
        let contentOfVisitorView = ContentOfVisitorView()
        contentOfVisitorView.setNoteInfoDic(noteInfoDictionary: noteInfoDictionary)
        
        //为contentOfVisitorView及其父视图visitorView添加约束
        contentOfVisitorView.translatesAutoresizingMaskIntoConstraints = false
        visitorView.addSubview(contentOfVisitorView)
        
        let leadingConstraint_COVV_VV = NSLayoutConstraint(item: contentOfVisitorView, attribute: .leading, relatedBy: .equal, toItem: visitorView, attribute: .leading, multiplier: 1.0, constant: contentOfVisitorView.margin)
        let trailingConstraint_COVV_VV = NSLayoutConstraint(item: contentOfVisitorView, attribute: .trailing, relatedBy: .equal, toItem: visitorView, attribute: .trailing, multiplier: 1.0, constant: -contentOfVisitorView.margin)
        
        let topConstraint_COVV_VV = NSLayoutConstraint(item: contentOfVisitorView, attribute: .top, relatedBy: .equal, toItem: visitorView, attribute: .top, multiplier: 1.0, constant: (kScreenHeight() - kStatusBarHeight() - kNavigationBarHeight() - kTabBarHeight() - contentOfVisitorView.selfHeight) / 2)
        let bottomConstraint_COVV_VV = NSLayoutConstraint(item: contentOfVisitorView, attribute: .bottom, relatedBy: .equal, toItem: visitorView, attribute: .bottom, multiplier: 1.0, constant: -(kScreenHeight() - kStatusBarHeight() - kNavigationBarHeight() - kTabBarHeight() - contentOfVisitorView.selfHeight) / 2)
        
        visitorView.addConstraints([leadingConstraint_COVV_VV, trailingConstraint_COVV_VV, topConstraint_COVV_VV, bottomConstraint_COVV_VV])

        //为contentOfVisitorView中的按钮添加响应函数
        contentOfVisitorView.registerBtn.addTarget(self, action: #selector(register), for: .touchUpInside)
        contentOfVisitorView.logonBtn.addTarget(self, action: #selector(logon), for: .touchUpInside)
    }
}

//MARK: BaseViewController分类：基于视图表格，子类去重写
extension BaseViewController : UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let sectionMaxIndex = tableView.numberOfSections - 1
        let rowMaxIndex = tableView.numberOfRows(inSection: sectionMaxIndex) - 1
        
        //最后一个secton的最后一个row将要显示时，并且当前内容的高度 >= tableView的高度
        if isPullDown == false && isPullUp == false && indexPath.row == rowMaxIndex && tableView.contentSize.height >= tableView.bounds.height{
            print("willDisplay cell \(indexPath.row), \(rowMaxIndex)")
            isPullUp = true
            loadData()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt")
    }
}

//MARK: 设置按钮响应
extension BaseViewController{
    @objc func register(){
        print("register")
    }
    
    @objc func logon(){
        //发送登录通知
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: logonNotification), object: nil)
    }
}


