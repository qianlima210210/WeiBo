//
//  ComposeViewController.swift
//  WeiBo
//
//  Created by QDHL on 2018/3/28.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "退出",
                                                                style: .done,
                                                                target: self,
                                                                action: #selector(exit))
    }

     @objc func exit() -> Void {
        dismiss(animated: true, completion: nil)
    }

}
