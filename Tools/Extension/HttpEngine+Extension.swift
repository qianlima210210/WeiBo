//
//  HttpEngine+Extension.swift
//  WeiBo
//
//  Created by QDHL on 2018/1/26.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import Foundation

//MARK：封装应用中网络请求
extension HttpEngine {
    /// 请求状态列表
    ///
    /// - Parameter completionHandler: 请求结果回调
    func statusesList(completionHandler:@escaping (_ list:[[String: Any]]?, _ error: Error?)->Void) {
        cancelStatusesListRequest()
        
        let url = "https://api.weibo.com/2/statuses/home_timeline.json"
        dataRequestOfStatusesList = httpRequest(requestKey:"statusesList", url: url, parameters: nil) { (value: Any?, error: Error?) in
            if error != nil {
                completionHandler(nil, error)
            }else{
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
}
