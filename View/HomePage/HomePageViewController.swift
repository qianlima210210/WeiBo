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
    
    override func loadData() {
        for i in 0..<20 {
            dataList.insert(i.description, at: 0)
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

