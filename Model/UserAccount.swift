//
//  UserAccount.swift
//  WeiBo
//
//  Created by QDHL on 2018/2/8.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

class UserAccount: NSObject {

    @objc var access_token: String?
    @objc var uid: String?
    @objc var expires_in: TimeInterval = 0.0
    
    //静态单例
    static let userAccount = UserAccount()
    
    override init() {
        access_token = ""
        uid = ""
        
        super.init()
    }
    
    override var description: String{
        return yy_modelDescription()
    }
    
    func initUserAccount(userAccount: UserAccount) -> Void {
        access_token = userAccount.access_token ?? ""
        uid = userAccount.uid ?? ""
        expires_in = userAccount.expires_in >= 0.0 ? userAccount.expires_in : 0.0
    }
}
