//
//  MQLRefreshControl.swift
//  WeiBo
//
//  Created by QDHL on 2018/3/22.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

class MQLRefreshControl: UIControl {
    
    //刷新控件的父视图，下拉刷新控件应适用于UITableView/UICollectionView
    private weak var scrollView: UIScrollView?
    var refreshing: Bool = false
    
    //MARK: 构造函数
    init() {
        super.init(frame: CGRect())
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        setUI()
    }
    
    deinit {
        scrollView?.removeObserver(self, forKeyPath: "contentOffset", context: nil)
    }
    
    /// 当视图作为子视图被添加时，其willMove（toSuperview：）被调用
    /// 当父视图被移除时，其willMove（toSuperview：）被调用
    /// - Parameter newSuperview: 当添加到父视图的时候，newSuperview就是父视图；当父视图被移除，newSuperview为nil
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        //判断父视图的类型
        guard let sv = newSuperview as? UIScrollView else { return  }
        //记录父视图
        scrollView = sv
        
        //KVO监听父视图的contentOffset
        scrollView?.addObserver(self, forKeyPath: "contentOffset", options: [.new, .old], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let sv = scrollView else { return  }
        let height = -sv.contentOffset.y
        
        //设置控件frame
        frame = CGRect(x: 0, y: -height, width: sv.bounds.width, height: height)
    }
    
    //MARK:开始刷新
    func beginRefreshing() {
        
    }
    
    //MARK:结束刷新
    func endRefreshing() {
        
    }
}

extension MQLRefreshControl {
    func setUI() -> Void {
        backgroundColor = UIColor.orange
    }
}











