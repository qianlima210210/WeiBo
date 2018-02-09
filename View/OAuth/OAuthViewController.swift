//
//  OAuthViewController.swift
//  WeiBo
//
//  Created by QDHL on 2018/2/5.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit
import WebKit
import SVProgressHUD

class OAuthViewController: BaseViewController, WKNavigationDelegate {

    var webView = WKWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setNavigationTitle(title: "登录")
        setNavigationLeftBtn(title: "关闭", target: self, action: #selector(closeBtnClicked))
    }
    
    @objc func closeBtnClicked() -> Void {
        self.dismiss(animated: true) {
            
        }
    }
    
    override func setUI() -> Void {
        super.setUI()
        addWebView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /// 添加webView
    func addWebView() -> Void {
        webView.navigationDelegate = self
        webView.scrollView.isScrollEnabled = false
        
        //为webView及其父视图view添加约束
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        let leftConstraint_WV_V = NSLayoutConstraint(item: webView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0.0)
        let topConstraint_WV_V = NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: newNavigationBarBackgroundView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        let widthConstraint_WV_V = NSLayoutConstraint(item: webView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0.0)
        let bottomConstraint_WV_V = NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        
        view.addConstraints([leftConstraint_WV_V, topConstraint_WV_V, widthConstraint_WV_V, bottomConstraint_WV_V])
    
        //设置访问的url
        let url = URL(string: "https://api.weibo.com/oauth2/authorize?client_id=\(AppKey)&redirect_uri=\(OAuthCallbackUrl)")
        if let url = url {
            let requeset = URLRequest(url: url)
            webView.load(requeset)
        }
    
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

//MARK: WKNavigationDelegate实现
extension OAuthViewController {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void){
        if let absoluteString = navigationAction.request.url?.absoluteString {
            if absoluteString.hasPrefix(successOAuthCallbackUrlPrefix){
                //1、成功授权回调地址被调用
                print("成功授权回调地址：\(absoluteString)")
                let code = (absoluteString as NSString).substring(from: successOAuthCallbackUrlPrefix.count)
                print("授权码：\(code)")
                decisionHandler(.cancel)
                
                //2、获取访问令牌
                SVProgressHUD.show()
                HttpEngine.httpEngine.getAccessToken(code: code, completionHandler: { (result, error) in
                    if error != nil{
                        
                    }else{
                        if let result = result {
                            UserAccount.userAccount.yy_modelSet(withJSON: result)
                            print(UserAccount.userAccount)
                            UserAccount.userAccount.saveUserAccount()
                        }
                    }
                    SVProgressHUD.dismiss()
                    self.closeBtnClicked()
                })
                return
            }
        }
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!){
        print("didStartProvisionalNavigation")
        SVProgressHUD.show()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error){
        print("didFailProvisionalNavigation")
        SVProgressHUD.dismiss()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
        print("didFinish")
        SVProgressHUD.dismiss()
        
        let jsString = "document.getElementById('userId').value = ''; document.getElementById('passwd').value = '';"
        webView.evaluateJavaScript(jsString) { (result, error) in
        }
    }
}
