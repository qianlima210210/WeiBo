//
//  HttpEngine.swift
//  WeiBo
//
//  Created by QDHL on 2018/1/26.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import Foundation
import Alamofire

class NoteError: Error {
    
}

//MARK: 定义请求回调闭包
typealias httpRequestCompletionHandler = (Any?, Error?) ->Void

class HttpEngine: NSObject {
    
    static let httpEngine = HttpEngine()
    
    var dataRequestOfStatusesList: DataRequest?
    var dataRequestOfUID: DataRequest?
    var dataRequestOfUnread_count: DataRequest?
    var dataRequestOfAccessToken: DataRequest?
    var dataRequestOfUserInfo: DataRequest?
    var dataRequestOfPublishWeiBo: DataRequest?
    
    /// 发送登录后的http请求
    ///
    /// - Parameters:
    ///   - url: 请求地址
    ///   - method: 请求方式
    ///   - parameters: 请求参数
    ///   - encoding: url编码方式
    ///   - headers: 请求头
    ///   - completionHandler: 请求完成回调（通过对HttpResponse错误是否为nil做第一层的判断，即网络传输层是否正常；第二层是表示服务器理解了本次请求，但是否合法还需通过Status Code和返回的信息判断。）
    func httpRequestAfterLogoned(
        url: String,
        method: HTTPMethod = .get,
        parameters: [String:Any]?,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil, completionHandler: @escaping httpRequestCompletionHandler)-> DataRequest?
    {
        //判断access_token是否有值
        guard let access_token = UserAccount.userAccount.access_token else {
            //手动触发请求完成回调
            completionHandler(nil, WBCustomNSError(errorDescription: "access_token为nil"))
            
            //通知登录去获取access_token
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: logonNotification), object: nil, userInfo:["showAlert":true])
            
            return nil
        }
        
        //添加请求参数及公共参数
        var mutableParameters = [String: Any]()
        if let parameters = parameters {
            for (key, value) in parameters{
                mutableParameters[key] = value
            }
        }
        mutableParameters["access_token"] = access_token
        
        //调用AF
        let dataRequest =  request(url, method: method, parameters: mutableParameters, encoding: encoding, headers: headers)
        dataRequest.responseJSON(queue: DispatchQueue.main, options: .allowFragments) { (dataResponse:DataResponse<Any>) in
            //请求成功
            if dataResponse.result.isSuccess {
                //先处理Status Code: 403的问题（该状态表示服务器理解了本次请求但是拒绝执行该任务）
                if dataResponse.response?.statusCode == 403 {
                    //手动触发请求完成回调
                    completionHandler(nil, WBCustomNSError(errorDescription: "Status Code: 403"))
                    
                    //服务器禁止请求
                    UserAccount.userAccount.resetUserAccount()
                    
                    //通知登录去获取access_token
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: logonNotification), object: nil, userInfo:["showAlert":true])
                    
                    return
                }
                
                let value = dataResponse.value
                //请求完成回调
                completionHandler(value, nil)
            }else{//请求失败
                let error = dataResponse.error
                //请求完成回调
                completionHandler(nil, error)
            }
        }
        
        return dataRequest
    }
    
    func postHttpRequestAfterLogoned(
        url: String,
        parameters: [String:Any]?,
        name: String,
        data: Data,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil, completionHandler: @escaping httpRequestCompletionHandler)-> DataRequest?
    {
        //判断access_token是否有值
        guard let access_token = UserAccount.userAccount.access_token else {
            //手动触发请求完成回调
            completionHandler(nil, WBCustomNSError(errorDescription: "access_token为nil"))
            
            //通知登录去获取access_token
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: logonNotification), object: nil, userInfo:["showAlert":true])
            
            return nil
        }
        
        //添加请求参数及公共参数
        var mutableParameters = [String: Any]()
        if let parameters = parameters {
            for (key, value) in parameters{
                mutableParameters[key] = value
            }
        }
        mutableParameters["access_token"] = access_token
        
        //创建URL
        guard let url = URL(string: url) else {
            //手动触发请求完成回调
            completionHandler(nil, WBCustomNSError(errorDescription: "url为nil"))
            return nil
        }
        
        let request = URLRequest(url: url)
        
        //调用AF
        upload(multipartFormData: { (formData) in
            //添加文件数据
            formData.append(data, withName: "pic", mimeType: "image/png")
            
            //添加参数字典信息
            for (key, value) in parameters ?? [:] {
                //formData.append(value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
                guard let value = value as? String,
                    let data = value.data(using: String.Encoding.utf8) else {
                       continue
                }
                formData.append(data, withName: key)
            }
            
        }, with: request) { (result: SessionManager.MultipartFormDataEncodingResult) in
            switch result {
                
            case .success(let request, _,  _):
                request.response(completionHandler: { (response) in
                    
                })
            case .failure(_):
                break
            }
        }
        
        return nil
    }
    
    /// 发送登录前的http请求
    ///
    /// - Parameters:
    ///   - url: 请求地址
    ///   - method: 请求方式
    ///   - parameters: 请求参数
    ///   - encoding: url编码方式
    ///   - headers: 请求头
    ///   - completionHandler: 请求完成回调（通过对HttpResponse错误是否为nil做第一层的判断，即网络传输层是否正常；第二层是表示服务器理解了本次请求，但是否合法还需通过Status Code和返回的信息判断。）
    func httpRequestBeforeLogoned(
        url: String,
        method: HTTPMethod = .get,
        parameters: [String:Any]?,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil, completionHandler: @escaping httpRequestCompletionHandler)-> DataRequest?
    {
        //添加请求参数及公共参数
        var mutableParameters = [String: Any]()
        if let parameters = parameters {
            for (key, value) in parameters{
                mutableParameters[key] = value
            }
        }
        
        //调用AF
        let dataRequest =  request(url, method: method, parameters: mutableParameters, encoding: encoding, headers: headers)
        dataRequest.responseJSON(queue: DispatchQueue.main, options: .allowFragments) { (dataResponse:DataResponse<Any>) in
            //请求成功
            if dataResponse.result.isSuccess {
                let value = dataResponse.value
                //请求完成回调
                completionHandler(value, nil)
            }else{//请求失败
                let error = dataResponse.error
                //请求完成回调
                completionHandler(nil, error)
            }
        }
        
        return dataRequest
    }
    
}



