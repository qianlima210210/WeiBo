//
//  UserAccount.swift
//  WeiBo
//
//  Created by QDHL on 2018/2/8.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

class UserAccount: NSObject {

    @objc var access_token: String? //= "2.002SUK3C_5a2KB590f93dd00DxZ3yD"
    @objc var uid: String? //= "2159844793"
    @objc var expires_in: TimeInterval = 0.0 {
        didSet{
            expiresDate = Date(timeIntervalSinceNow: expires_in)
        }
    }
    
    @objc var expiresDate: Date?
    
    //静态单例
    static let userAccount = UserAccount()
    
    override init() {
        super.init()
        
        //从本地加载用户账号信息
        loadUserAccount()
    }
    
    override var description: String{
        return yy_modelDescription()
    }
    
    //从本地加载用户账号信息
    func loadUserAccount() -> Void {
        let filePath = NSHomeDirectory() + "/Documents/userAccount"
        let url = URL(fileURLWithPath: filePath)
        
        guard let data = try? Data(contentsOf: url),
            let dic = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String:Any] else {
            return
        }
        
        self.yy_modelSet(with: dic)
        
        //判断是否过期
        //FIXME: 测试访问令牌过期
        //expiresDate = Date(timeIntervalSinceNow: -3600)
        if expiresDate?.compare(Date()) == .orderedAscending {
            print("访问令牌过期")
            //1、将用户对象恢复初始化
            access_token = nil
            uid = nil
            expires_in = 0
            expiresDate = nil
            
            //2、删除用户账号文件
            try? FileManager.default.removeItem(at: url)
            
        }else{
            print("访问令牌NO过期")
        }
        
        
    }
    
    /// 存入本地
    func saveUserAccount() -> Void {
        //1.模型转字典
        var dic = (yy_modelToJSONObject() as? [String:Any]) ?? [:]
        
        //1.1去除expires_in
        dic.removeValue(forKey: "expires_in")
        
        //2.字典转Data
        guard let data = try? JSONSerialization.data(withJSONObject: dic, options: []) else {
            return
        }
        
        //3.写入磁盘
        let filePath = NSHomeDirectory() + "/Documents/userAccount"
        let url = URL(fileURLWithPath: filePath)
        try? data.write(to: url)
        print("用户账号信息地址：\(filePath)")
    }
}
