//
//  HomePageViewController.swift
//  WeiBo
//
//  Created by QDHL on 2018/1/9.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

class HomePageViewController: BaseViewController {
    private let normalReuseIdentifier = "normalReuseIdentifier"
    private let retweetedReuseIdentifier = "retweetedReuseIdentifier"
    
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
    
    override func setUI(_ onlyNav: Bool) {
        super.setUI()
        
        UserAccount.userAccount.isLogon ? setNavigationTitleButton(target: self,
                                                                   action: #selector(titleBtnClicked(sender: ))) : setNavigationTitle(title: "首页")
        setNavigationLeftBtn(title: UserAccount.userAccount.isLogon ? "好友":"注册", target: self, action: #selector(leftBtnClicked))
        setNavigationRightBtn(title: UserAccount.userAccount.isLogon ? "":"登录", target: self, action: #selector(rightBtnClicked))
        
        tableView.register(UINib(nibName: "StatusNormalCell", bundle: nil),
                           forCellReuseIdentifier: normalReuseIdentifier)
        tableView.register(UINib(nibName: "StatusRetweetedCell", bundle: nil),
                           forCellReuseIdentifier: retweetedReuseIdentifier)


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
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
            self.listViewModel.loadStatus(isPullUp: self.isPullUp) { (isSuccess) in
                print("请求数据结束\(Date())")
                
                if self.isPullDown{
                    self.isPullDown = false
                    self.refreshCtl.endRefreshing()
                    
                }else{
                    self.isPullUp = false
                }
                
                if isSuccess {
                    self.tableView.reloadData()
                }
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
        //获取视图模型，判断是否是“转发微博”，来设置重用标识
        let vm = listViewModel.statusList[indexPath.row]
        let cellId = vm.status?.retweeted_status != nil ? retweetedReuseIdentifier : normalReuseIdentifier
        
        //根据重用标识，获取cell
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! StatusCellTableViewCell
        cell.delegate = self
        
        cell.statusViewModel = vm
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return listViewModel.statusList[indexPath.row].cellHeight
    }
}

extension HomePageViewController : StatusCellTableViewCellDelegate {
    func statusCellTableViewCellURLClicked(cell: StatusCellTableViewCell?, string: String?) {
        let vc = WebViewController()
        vc.urlString = string
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func statusCellTableViewCellPhoneNumClicked(cell: StatusCellTableViewCell?, string: String?) {
        print(string ?? "")
    }
    
    func statusCellTableViewCellEmailClicked(cell: StatusCellTableViewCell?, string: String?) {
        print(string ?? "")
    }
}
