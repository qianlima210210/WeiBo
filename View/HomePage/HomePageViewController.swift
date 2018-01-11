//
//  HomePageViewController.swift
//  WeiBo
//
//  Created by QDHL on 2018/1/9.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

class HomePageViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        newNavigationItem.leftBarButtonItem = UIBarButtonItem(title: "好友", target: self, action: #selector(friendsBtnClicked(sender:)))
    }

    @objc func friendsBtnClicked(sender: UIBarButtonItem) -> Void {
        let vc = DemoViewController()
        navigationController?.pushViewController(vc, animated: true)
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
