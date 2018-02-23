//
//  UIImage+Extension.swift
//  WeiBo
//
//  Created by QDHL on 2018/2/23.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import Foundation

extension UIImage {
    func imageWithoutColorMisaligned(size: CGSize, backColor: UIColor?) -> UIImage? {
        let rect = CGRect(origin: CGPoint(), size: size)
        
        //1.获取图形上下文：在内存中开辟一块空间，与屏幕无关
        /**
         size: 绘图的尺寸
         不透明: true/false
         scale:屏幕分辨率，指定0，会指定当前设备的屏幕分辨率
         */
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
        
        //1.1背景填充
        backColor?.setFill()
        UIRectFill(rect)
        
        //1.2实例化一个圆形的路径
        let path = UIBezierPath(ovalIn: rect)
        
        //1.3进行路径裁剪，后续的绘图都会出现在圆内，外部都干掉
        path.addClip()
        
        //2.绘图
        draw(in: rect)
        
        //3.绘制内切圆形
        UIColor.red.setStroke()
        path.lineWidth = 2
        path.stroke()
        
        //4.取得结果
        let result = UIGraphicsGetImageFromCurrentImageContext()
        
        //5.关闭上下文
        UIGraphicsEndImageContext()
        
        //6.返回结果
        return result
    }
}





