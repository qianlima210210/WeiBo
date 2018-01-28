//
//  WBStatusListViewModel.swift
//  WeiBo
//
//  Created by QDHL on 2018/1/27.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import Foundation
//所有的视图模型，都用来从试图控制器中抽出来的处理逻辑
/*
 父类的选择
 - 如果类需要使用KVC或者字典转模型设置对象属性，类就需要继承自NSObject
 - 如果类只是包装一些代码逻辑（谢了一些函数），可以不用任何父类，好处：更加轻量级
 - 提示：如果用OC写，一律继承自NSObject
 
 本类功能：负责微博的数据处理
 1、字段转模型
 2、下拉、上拉刷新数据处理
 */

/// 微博数据列表视图模型
class WBStatusListViewModel {
    //微博模型列表
    var statusList = [WBStatus]()
    
    
    /// 加载微博列表
    ///
    /// - Parameter completion: 完成回调（数据是否成功获取）
    func loadStatus(completion:@escaping (_ isSuccess: Bool)->()) {
        //since_id：去除数组中第一条微博的ID
        let since_id = statusList.first?.id ?? 0
        HttpEngine.httpEngine.statusesList(since_id: since_id) { (value, error) in
            if error == nil{
                //1、字典转模型
                guard let list = NSArray.yy_modelArray(with: WBStatus.self, json: value ?? []) as? [WBStatus] else{
                    //完成回调
                    completion(false)
                    return
                }
                
                //2、拼接数据
                //-- 下拉刷新，应将返回数据拼接在列表的前面
                //-- 上拉刷新，应将返回数据拼接在列表的后面
                self.statusList = list + self.statusList
                
                //完成回调
                completion(true)
            }
        }
    }
}


























