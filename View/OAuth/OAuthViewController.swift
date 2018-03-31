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
    }
    
    @objc func closeBtnClicked() -> Void {
        SVProgressHUD.dismiss()
        self.dismiss(animated: true) {
            
        }
    }
    
    override func setUI(_ onlyNav: Bool) -> Void {
        if UserAccount.userAccount.isLogon == false {
            super.setUI()
            
            setNavigationTitle(title: "登录")
            setNavigationLeftBtn(title: "关闭", target: self, action: #selector(closeBtnClicked))
            
            addWebView()
        }
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
    
        //设置访问的url(同意授权后会重定向,我们通过拦截重定向获取授权码)
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
            if absoluteString.hasPrefix(OAuthCallbackUrl){
                //1、先取消请求
                decisionHandler(.cancel)
                
                //2、判断成功/失败授权回调
                if absoluteString.contains(SuccessOAuthKey) {//成功授权回调
                    print("成功授权回调地址：\(absoluteString)")
                    let code = (absoluteString as NSString).substring(from: (OAuthCallbackUrl + SuccessOAuthKey).count)
                    print("授权码：\(code)")

                    //2.获取访问令牌
                    SVProgressHUD.show()
                    HttpEngine.httpEngine.getAccessToken(code: code, completionHandler: { (result, error) in
                        SVProgressHUD.dismiss()
                        
                        if error != nil{
                            SVProgressHUD.showInfo(withStatus: "授权失败")
                        }else{
                            if let result = result {
                                UserAccount.userAccount.yy_modelSet(with: result)
                                
                                //请求用户信息
                                SVProgressHUD.show()
                                HttpEngine.httpEngine.getUserInfo(completionHandler: { (result, error) in
                                    SVProgressHUD.dismiss()
                                    
                                    if error != nil {
                                        SVProgressHUD.showInfo(withStatus: "授权失败")
                                    }else{
                                        if let result = result {
                                            //获取昵称及头像地址
                                            UserAccount.userAccount.yy_modelSet(with: result)
                                            print(UserAccount.userAccount)
                                            UserAccount.userAccount.saveUserAccount()
                                        }
                                        
                                        SVProgressHUD.showInfo(withStatus: "登录成功并成功授权")
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: logonAndAOthSuccessNotification), object: nil)
                                        self.closeBtnClicked()
                                    }
                                    
                                    

                                })
                            }
                        }

                    })
                    return
                }else{//失败授权回调
                    SVProgressHUD.showInfo(withStatus: "取消授权")
                }
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
        
        let jsString = "document.getElementById('userId').value = 'qianlima210210@163.com'; document.getElementById('passwd').value = 'mchzmql1366';"
        webView.evaluateJavaScript(jsString) { (result, error) in
        }
    }
}
