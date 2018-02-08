//
//  HttpEngine+Extension.swift
//  WeiBo
//
//  Created by QDHL on 2018/1/26.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import Foundation
import Alamofire

//MARK：封装应用中网络请求
extension HttpEngine {

    ///  请求状态列表
    ///
    /// - Parameters:
    ///   - since_id: 若指定此参数，则返回ID比since_id大的微博（即比since_id时间晚的微博），默认为0。
    ///   - max_id: 若指定此参数，则返回ID小于或等于max_id的微博，默认为0。
    /// - Parameter completionHandler: 请求结果回调
    func statusesList(since_id: Int64 = 0, max_id: Int64 = 0, completionHandler:@escaping (_ list:[[String: Any]]?, _ error: Error?)->Void) {
        //先取消上一个请求
        cancelStatusesListRequest()
        
        //组织请求地址及参数并请求
        let parameters = ["since_id":since_id, "max_id":max_id]
        let url = "https://api.weibo.com/2/statuses/home_timeline.json"
        dataRequestOfStatusesList = httpRequestAfterLogoned(url: url, parameters: parameters) { (value: Any?, error: Error?) in
            if error != nil {
                completionHandler(nil, error)
            }else{
                //尝试转成你想要的类型
                if let result = ((value as? [String: Any])?["statuses"]) as? [[String:Any]]{
                    completionHandler(result, error)
                }else{
                    completionHandler(nil, WBCustomNSError(errorDescription: "返回信息格式有问题"))
                }
            }
        }
    }
    
    
    /// 取消状态列表请求
    func cancelStatusesListRequest() -> Void {
        guard let dataRequestOfStatusesList = dataRequestOfStatusesList else{
            return
        }
        dataRequestOfStatusesList.cancel()
        self.dataRequestOfStatusesList = nil
    }
    
    
    /// 获取账号UID
    func getUID(completionHandler:@escaping (_ dic: [String:Any]?, _ error: Error?)->Void) -> Void {
        // 取消账号UID请求
        cancelGetUID()
        
        //组织请求地址及参数并请求
        let url = "https://api.weibo.com/2/account/get_uid.json"
        dataRequestOfUID = httpRequestAfterLogoned(url: url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, completionHandler: { (value: Any?, error: Error?) in
            if error != nil {
                completionHandler(nil, error)
            }else{
                //尝试转成你想要的类型
                if let result = value as? [String:Any] {
                    completionHandler(result, error)
                }else{
                    completionHandler(nil, WBCustomNSError(errorDescription: "返回信息格式有问题"))
                }
            }
        })
    }
    
    /// 取消账号UID请求
    func cancelGetUID() -> Void {
        guard let dataRequestOfUID = dataRequestOfStatusesList else{
            return
        }
        dataRequestOfUID.cancel()
        self.dataRequestOfUID = nil
    }
    
    //获取用户的各种消息未读数
    func getUnread_count(completionHandler:@escaping (_ count: Int?, _ error: Error?) -> ()) -> Void {
        //判断uid是否为nil，这种公共参数后期需要整理分类
        guard let uid = UserAccount.userAccount.uid else {
            return
        }
        
        //取消用户的各种消息未读数请求
        cancelGetUnread_count()
        
        //组织请求地址及参数并请求
        let parameters = ["uid":uid]
        let url = "https://rm.api.weibo.com/2/remind/unread_count.json"
        
        dataRequestOfUnread_count = httpRequestAfterLogoned(url: url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil, completionHandler: { (value: Any?, error: Error?) in
            if error != nil {
                completionHandler(nil, error)
            }else{
                //尝试转成你想要的类型
                if let result = (value as? [String:Any])?["status"] as? Int {
                    completionHandler(result, error)
                }else{
                    completionHandler(nil, WBCustomNSError(errorDescription: "返回信息格式有问题"))
                }
            }
        })
    }
    
    //取消用户的各种消息未读数请求
    func cancelGetUnread_count() -> Void {
        guard dataRequestOfUnread_count != nil else {
            return
        }
        dataRequestOfUnread_count?.cancel()
        dataRequestOfUnread_count = nil
    }
}

extension HttpEngine {
    //获取授权过的Access Token
    func getAccessToken(code: String, completionHandler:@escaping (_ dic: [String:Any]?, _ error: Error?) ->()) -> Void {
        //取消获取授权过的Access Token请求
        cancelGetAccessToken()
        
        //组织请求地址及参数并请求
        let parameters = ["client_id":AppKey,
                          "client_secret":AppSecret,
                          "grant_type":"authorization_code",
                          "code":code,
                          "redirect_uri":OAuthCallbackUrl]
        let url = "https://api.weibo.com/oauth2/access_token"
        dataRequestOfAccessToken = httpRequestBeforeLogoned(url: url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil, completionHandler: { (value: Any?, error: Error?) in
            if error != nil {
                completionHandler(nil, error)
            }else{
                //尝试转换成你想要的类型
                if let dic = value as? [String:Any]{
                    completionHandler(dic, nil)
                }else{
                    completionHandler(nil, WBCustomNSError(errorDescription: "返回信息格式有问题"))
                }
            }
        })
        
    }
    
    //取消获取授权过的Access Token请求
    func cancelGetAccessToken() -> Void {
        guard let dataRequestOfAccessToken = dataRequestOfAccessToken else {
            return
        }
        dataRequestOfAccessToken.cancel()
        self.dataRequestOfAccessToken = nil
    }
}

















