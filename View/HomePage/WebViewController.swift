//
//  WebViewController.swift
//  WeiBo
//
//  Created by QDHL on 2018/3/31.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: BaseViewController {
    
    var webView = WKWebView()
    var urlString: String? {
        didSet{
            guard let urlString = urlString,
            let url = URL(string: urlString) else { return }
            
            let request = URLRequest.init(url: url)
            webView.load(request)
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
        
        //为webView及其父视图view添加约束
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.backgroundColor = UIColor.cyan
        view.addSubview(webView)
        
        let leftConstraint_WV_V = NSLayoutConstraint(item: webView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0.0)
        let topConstraint_WV_V = NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: newNavigationBarBackgroundView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        let widthConstraint_WV_V = NSLayoutConstraint(item: webView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0.0)
        let bottomConstraint_WV_V = NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        
        view.addConstraints([leftConstraint_WV_V, topConstraint_WV_V, widthConstraint_WV_V, bottomConstraint_WV_V])
        
    }
    
    @objc func leftBtnClicked() -> Void {
        navigationController?.popViewController(animated: true)
    }

    override func setUI(_ onlyNav: Bool) {
        super.setUI(true)
        
        setNavigationTitle(title: "网页")
        setNavigationLeftBtn(title: "返回", target: self, action: #selector(leftBtnClicked))
    }

}
