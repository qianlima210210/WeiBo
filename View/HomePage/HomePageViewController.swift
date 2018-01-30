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
        setNavigationTitle(title: "首页")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
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
            print("上拉前最后一条数据是：" + (listViewModel.statusList.last?.text ?? ""))
        }else{
            print("下拉前第一条数据是：" + (listViewModel.statusList.first?.text ?? ""))
        }
        
        
        listViewModel.loadStatus(isPullUp: isPullUp) { (isSuccess) in
            print("请求数据结束\(Date())")
            self.isPullDown = false
            self.isPullUp = false
            self.refreshCtl.endRefreshing()
            self.tableView.reloadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text = listViewModel.statusList[indexPath.row].text
        
        return cell
    }
}

