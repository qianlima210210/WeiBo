//
//  EmotionTextAttachment.swift
//  表情键盘
//
//  Created by maqianli on 2018/4/5.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

/// 表情文本附件
class EmotionTextAttachment: NSTextAttachment {
    /// 附件对应的表情名字符串，用于发送给服务器（这样就节约流量了）
    var chs: String?
}
