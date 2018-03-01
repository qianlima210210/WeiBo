//
//  WBThumbnailPic.swift
//  WeiBo
//
//  Created by QDHL on 2018/2/28.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

@objcMembers class WBThumbnailPic: NSObject {

    var thumbnail_pic: String?{
        didSet{
            if let thumbnail_pic = thumbnail_pic {
                //这里应该有个网络类型的判断：WiFi下载bmiddle；GPRS下载thumbnail
                self.thumbnail_pic = thumbnail_pic.replacingOccurrences(of: "bmiddle", with: "large")
            }
        }
    }
    
    override var description: String{
        return yy_modelDescription()
    }
}
