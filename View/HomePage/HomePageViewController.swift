//
//  HomePageViewController.swift
//  WeiBo
//
//  Created by QDHL on 2018/1/9.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

class HomePageViewController: BaseViewController {
    let reuseIdentifier = "reuseIdentifier"
    //列表视图模型
    var listViewModel = WBStatusListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @objc func leftBtnClicked() -> Void {
        if UserAccount.userAccount.isLogon {
            print("HomePageViewController leftBtnClicked 好友")
        }else{
            print("HomePageViewController leftBtnClicked 注册")
        }
    }
    
    @objc func titleBtnClicked(sender:UIButton) -> Void {
        sender.isSelected = !sender.isSelected
    }
    
    @objc func rightBtnClicked() -> Void {
        if UserAccount.userAccount.isLogon {
            print("HomePageViewController rightBtnClicked")
        }else{
            print("HomePageViewController rightBtnClicked 登录")
            //发送登录通知
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: logonNotification), object: nil)
        }
    }
    
    override func setUI() {
        super.setUI()
        
        UserAccount.userAccount.isLogon ? setNavigationTitleButton(target: self,
                                                                   action: #selector(titleBtnClicked(sender: ))) : setNavigationTitle(title: "首页")
        setNavigationLeftBtn(title: UserAccount.userAccount.isLogon ? "好友":"注册", target: self, action: #selector(leftBtnClicked))
        setNavigationRightBtn(title: UserAccount.userAccount.isLogon ? "":"登录", target: self, action: #selector(rightBtnClicked))
        
        tableView.register(UINib(nibName: "StatusNormalCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        //只有数据为空的情况下，才会自动尝试获取
        if listViewModel.statusList.count == 0 {
            super.viewDidAppear(animated)
        }
    }
    
    //重写父类的加载
    override func loadData() {
        if isPullUp {
            print("上拉前最后一条数据是：" + (listViewModel.statusList.last?.status?.text ?? ""))
        }else{
            print("下拉前第一条数据是：" + (listViewModel.statusList.first?.status?.text ?? ""))
        }
        
        
        listViewModel.loadStatus(isPullUp: isPullUp) { (isSuccess) in
            print("请求数据结束\(Date())")
            
            if self.isPullDown{
                self.isPullDown = false
                self.refreshCtl.endRefreshing()
                self.tableView.contentOffset = CGPoint(x: 0.0, y: 0.0)
            }else{
                self.isPullUp = false
            }
            
            if isSuccess {
                self.tableView.reloadData()
            }
        }
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

//extension不能重写本类方法，但是能重写本类中的已extension的方法
extension HomePageViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listViewModel.statusList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! StatusCellTableViewCell
        
        cell.statusViewModel = listViewModel.statusList[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        //这里返回的是UITableViewCell的高度，但是内容是放在其contentView上的，contentView高度默认比UITableViewCell高度小0.63,所以要额外加上这0.63
        let height0 = CGFloat(0.63)
        
        //正文以上的高度
        let height1 = CGFloat(66.0)
        
        //正文的高度
        var height2:CGFloat = 0.0
        if let zhengWen = listViewModel.statusList[indexPath.row].status?.text {
            height2 = zhengWen.heightOfString(size: CGSize(width: kScreenWidth() - CGFloat(12 * 2), height: CGFloat(1000.0)),
                                                  font: UIFont.systemFont(ofSize: 13),
                                                  lineSpacing: 5.0)
        }
        
        //图片视图容器的高度
        var height3 = CGFloat(0.0)
        let vm = listViewModel.statusList[indexPath.row]
        height3 = vm.prictureViewSize.height
        
        //图片视图容器和分割线的距离
        let height4 = CGFloat(6.0)
        
        //分割线的高度
        let height5 = CGFloat(1.0)
        
        //转发、评论、赞所在区域的高度
        let height6 = CGFloat(28.0)
        
        return height0 + height1 + height2 + height3 + height4 + height5 + height6
    }
}

