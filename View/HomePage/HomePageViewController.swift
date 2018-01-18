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
    var dataList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setNavigationTitle(title: "首页")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    //重写父类的加载
    override func loadData() {
        print("请求数据\(Date())")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            print("加载数据\(Date())")
            for i in 0..<3 {
                if self.isPullUp{
                    self.dataList.insert("pullUp" + i.description, at: 0)
                }else{
                    self.dataList.insert(i.description, at: 0)
                }
                
            }
            
            self.isPullUp = false
            self.tableView.reloadData()
            self.refreshCtl.endRefreshing()
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
        return dataList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text = dataList[indexPath.row]
        
        return cell
    }
}

