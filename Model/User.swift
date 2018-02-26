//
//  User.swift
//  WeiBo
//
//  Created by QDHL on 2018/2/26.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

class User: NSObject {

    //基本数据类型及私有属性，不能使用kvc设置？？？
    @objc var id: Int64 = 0
    
    @objc var screen_name: String?
    
    @objc var profile_image_url: String?
    
    //认证类型
    @objc var verified_type: Int = 0
    //会员等级
    @objc var mbrank: Int = 0
}
