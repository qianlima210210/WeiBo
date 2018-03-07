//
//  PictureContainerView.swift
//  WeiBo
//
//  Created by QDHL on 2018/2/28.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit
import SDWebImage

class PictureContainerView: UIView {
    //对应的视图模型
    var vm: WBStatusViewModel? {
        didSet{
            let view0 = subviews[0]
            
            guard let vm = vm,
               let picURLs = vm.picURLs else {
                return
            }
            if picURLs.count == 1 {
                //1、单图对subviews[0].frame特殊设置
                view0.frame = CGRect(x: 0,
                                     y: pictureTopMargin,
                                     width: vm.prictureViewSize.width,
                                     height: vm.prictureViewSize.height - pictureTopMargin)
            }else{
                //2、多图对subviews[0].frame恢复设置
                view0.frame = CGRect(x: 0,
                                     y: pictureTopMargin,
                                     width: pictureWidth,
                                     height: pictureWidth)
            }
            
            pic_urls = vm.picURLs
        }
    }
    
    //预览图数组
    var pic_urls:[WBThumbnailPic]?{
        didSet{
            //first将所有imageView隐藏
            for view in subviews {
                (view as! UIImageView).image = nil
                view.isHidden = true
            }

            //设置并显示有图的imageView
            var index = 0
            for item in pic_urls ?? [] {
                let url =  URL(string: item.thumbnail_pic ?? "")

                let imageView = subviews[index] as! UIImageView
                imageView.sd_setImage(with: url, placeholderImage: nil, options: [], completed: { (image, error, type, url) in
                })
                imageView.isHidden = false
                
                //特殊设置4张图的布局
                if pic_urls!.count == 4 && index == 1 {
                    index += 1
                }

                index += 1
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //每行三个图片视图
        let count = 3
        
        //每个图片视图大小
        let size = CGSize(width: pictureWidth, height: pictureWidth)
        
        for i in 0 ..< count * count {
            
            //第几行
            let row = CGFloat(i / count)
            //第几列
            let column = CGFloat(i % count)
            
            //图片视图起始坐标
            let point =  CGPoint(x: column * (pictureWidth + pictureMargin),
                    y: pictureTopMargin + row * (pictureWidth + pictureMargin))
            
            let imageView = UIImageView(frame: CGRect(origin: point, size: size))
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            
            addSubview(imageView)
        }
    }

}
