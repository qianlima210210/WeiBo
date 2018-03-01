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
            //先设置控件的高度
            setPrictureViewSize(count: status?.pic_urls?.count ?? 0)
            //最后统计cell总高度
            setCellHeight()
        }
    }
    
    //该视图模型对应的cell高度
    var cellHeight: CGFloat = 0.0
    
    //该视图模型对应的图片视图的大小
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
    
    
    /// 计算cell高度
    private func setCellHeight() -> Void {
        //这里返回的是UITableViewCell的高度，但是内容是放在其contentView上的，contentView高度默认比UITableViewCell高度小0.63,所以要额外加上这0.63
        let height0 = CGFloat(0.63)
        
        //正文以上的高度
        let height1 = CGFloat(66.0)
        
        //正文的高度
        var height2:CGFloat = 0.0
        if let zhengWen = status?.text {
            height2 = zhengWen.heightOfString(size: CGSize(width: kScreenWidth() - CGFloat(12 * 2), height: CGFloat(1000.0)),
                                              font: UIFont.systemFont(ofSize: 13),
                                              lineSpacing: 5.0)
        }
        
        //图片视图容器的高度
        var height3 = CGFloat(0.0)
        height3 = prictureViewSize.height
        
        //图片视图容器和分割线的距离
        let height4 = CGFloat(6.0)
        
        //分割线的高度
        let height5 = CGFloat(1.0)
        
        //转发、评论、赞所在区域的高度
        let height6 = CGFloat(28.0)
        
        cellHeight = height0 + height1 + height2 + height3 + height4 + height5 + height6
    }
}


