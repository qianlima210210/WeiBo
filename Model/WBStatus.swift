//
//  WBStatus.swift
//  WeiBo
//
//  Created by QDHL on 2018/1/27.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit
import YYModel

@objcMembers class WBStatus: NSObject{
    
    var user: User?
    
    //微博ID，每一条微博都会分配一个ID
    var id: Int64 = 0
    //微博信息内容
    var text: String?
    
    //转发数
    var reposts_count: Int = 0
    
    //评论数
    var comments_count: Int = 0
    
    //表态数
    var attitudes_count: Int = 0
    
    //预览图数组
    var pic_urls:[WBThumbnailPic]?
    
    override var description: String{
        return yy_modelDescription()
    }
    
    //为第三方库指定属性类型
    class func modelContainerPropertyGenericClass() ->[String:AnyClass] {
        return ["pic_urls":WBThumbnailPic.self]
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
