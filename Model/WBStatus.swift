//
//  WBStatus.swift
//  WeiBo
//
//  Created by QDHL on 2018/1/27.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit
import YYModel

class WBStatus: NSObject{
    
    @objc dynamic var user: User?
    
    //微博ID，每一条微博都会分配一个ID
    @objc dynamic var id: Int64 = 0
    //微博信息内容
    @objc dynamic var text: String?
    
    //转发数
    @objc dynamic var reposts_count: Int = 0
    
    //评论数
    @objc dynamic var comments_count: Int = 0
    
    //表态数
    @objc dynamic var attitudes_count: Int = 0
    
    override var description: String{
        return yy_modelDescription()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
