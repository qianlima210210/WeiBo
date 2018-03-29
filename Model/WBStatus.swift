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
    //该条微博所属用户
    var user: User?
    
    //微博创建时间
    var created_at: String?
    
    //微博来源
    var source: String?
    
    //被转发的原创微博
    var retweeted_status: WBStatus?
    
    //预览图数组
    var pic_urls:[WBThumbnailPic]?
    
    //微博ID，每一条微博都会分配一个ID
    var id: Int64 = 0
    //微博信息内容
    var text: String?
    
    //转发数
    var reposts_count: Int = 0
    
    //评论数
    var comments_count: Int = 0
    
    //表态数，即点赞数
    var attitudes_count: Int = 0
    
    override var description: String{
        return yy_modelDescription()
    }
    
    //为第三方库(YYModel)指定属性类型
    class func modelContainerPropertyGenericClass() ->[String:AnyClass] {
        return ["pic_urls":WBThumbnailPic.self]
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
