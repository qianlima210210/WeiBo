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
    ///   - completionHandler: 请求回调
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
            completionHandler(nil, WBCustomNSError.access_token_nil_error())
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
                let value = dataResponse.value
                completionHandler(value, nil)
            }else{//请求失败
                let error = dataResponse.error
                completionHandler(nil, error)
            }
        }
        
        return dataRequest
    }
    
    
    
}



