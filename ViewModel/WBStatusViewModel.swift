//
//  WBStatusViewModel.swift
//  WeiBo
//
//  Created by QDHL on 2018/2/26.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import Foundation

//单条微博视图模型
class WBStatusViewModel {
    
    var status: WBStatus? {
        didSet{
            setPrictureViewSize(count: status?.pic_urls?.count ?? 0)
        }
    }
    
    var prictureViewSize: CGSize = CGSize()
    
    /// 根据图片个数设置图片视图高度
    ///
    /// - Parameter count: 图片数
    private func setPrictureViewSize(count: Int) -> Void {
        if count == 0 {
            prictureViewSize = CGSize()
        }else{
            //计算行数
            let pictureRowNum = CGFloat((count - 1) / 3 + 1)
            
            //总高
            let height = pictureTopMargin + pictureRowNum * pictureWidth + (pictureRowNum - 1) * pictureMargin
            prictureViewSize = CGSize(width: kScreenWidth(), height: height)
        }
    }
}


