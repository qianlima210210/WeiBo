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
            
            //图片顶部间隔
            let pictureTopMargin = CGFloat(12)
            
            //图片间距
            let pictureMargin = CGFloat(5.0)
            
            //图片高度/宽度
            let pictureWidth = (kScreenWidth() - CGFloat(12 * 2) - CGFloat(pictureMargin * 2)) / 3
            
            //计算行数
            let rowNum = CGFloat((count - 1) / 3 + 1)
            
            //总高
            let height = pictureTopMargin + rowNum * pictureWidth + (rowNum - 1) * pictureMargin
            prictureViewSize = CGSize(width: 100, height: height)
            
        }
    }
}


