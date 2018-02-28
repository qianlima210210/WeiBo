//
//  User.swift
//  WeiBo
//
//  Created by QDHL on 2018/2/26.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

@objcMembers class User: NSObject {

    //基本数据类型及私有属性，不能使用kvc设置？？？
    var id: Int64 = 0
    
    var screen_name: String?
    
    var profile_image_url: String?
    
    //认证类型
    var verified_type: Int = 0
    //会员等级
    var mbrank: Int = 0
}
