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
    var access_token: String? = "2.002SUK3C_5a2KB590f93dd00DxZ3yD"
    
    var dataRequestOfStatusesList: DataRequest?
    
    /// 发送http请求
    ///
    /// - Parameters:
    ///   - requestKey: 请求关键字
    ///   - url: 请求地址
    ///   - method: 请求方式
    ///   - parameters: 请求参数
    ///   - encoding: url编码方式
    ///   - headers: 请求头
    ///   - completionHandler: 请求完成回调（通过对HttpResponse错误是否为nil做第一层的判断，即网络传输层是否正常；第二层是表示服务器理解了本次请求，但是否合法还需通过Status Code和返回的信息判断。）
    func httpRequest(
        requestKey:String,
        url: String,
        method: HTTPMethod = .get,
        parameters: [String:Any]?,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil, completionHandler: @escaping httpRequestCompletionHandler)-> DataRequest?
    {
        //判断access_token是否有值
        guard let access_token = access_token else {
            //手动触发请求完成回调
            completionHandler(nil, WBCustomNSError(errorDescription: "access_token为nil"))
            
            //TODO: 通知登录去获取access_token
            
            return nil
        }
        
        //添加公共参数
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
                    
                    //TODO: 通知登录去获取access_token
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
    
    
    
}



