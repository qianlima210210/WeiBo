//
//  MQLRefreshControl.swift
//  WeiBo
//
//  Created by QDHL on 2018/3/22.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit


/// 刷新状态
///
/// - Normal: 普通状态，设么都不做
/// - Pulling: 超过临界点，没有放手
/// - WillRefresh:超过临界点，已放手
enum RefreshState {
    case Normal
    case Pulling
    case WillRefresh
}

//仅仅提供对外的逻辑处理入口
class MQLRefreshControl: UIControl {
    
    //刷新控件的父视图，下拉刷新控件应适用于UITableView/UICollectionView
    private weak var scrollView: UIScrollView?
    
    let refreshView = MQLRefreshView.initMQLRefreshViewFromNib()
    var refreshing: Bool = false
    
    //刷新状态切换的临界点
    let refreshOffset = CGFloat(44.0)
    
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
    
    
    /// 当视图从父视图移除时调用
    /// 所有的刷新控件都是监听父视图的contentOffset
    override func removeFromSuperview() {
        //superview还存在
        superview?.removeObserver(self, forKeyPath: "contentOffset")
        super.removeFromSuperview()
        //superview不存在
    }
    
    /// 所有KVO方法统一调用此方法
    /// 在开发中通常只监听某一个对象的某几个属性，如果属性太多这个方法显得很乱
    /// 观察者模式在不需要的时候要及时释放
    /// 通知中心，如果不释放，什么也不会发生，但是会出现内存泄漏，这样造成注册多次
    /// KVO如果不释放，会crash
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let sv = scrollView else { return  }
        let height = -sv.contentOffset.y
        
        //向上拖动不处理
        if height < 0 {
            return;
        }
        
        //设置控件frame
        frame = CGRect(x: 0, y: -height, width: sv.bounds.width, height: height)
        
        //判断临界点
        if sv.isDragging {
            if height > refreshOffset && refreshView.refreshState == .Normal{
                print("可以放手刷新了")
                refreshView.refreshState = .Pulling
            }else if height <= refreshOffset && refreshView.refreshState == .Pulling{
                print("过临界点，又拖回来了")
                refreshView.refreshState = .Normal
            }
        }else{
            //放手
            if refreshView.refreshState == .Pulling {
                print("可以刷新了")
                beginRefreshing()
                
                sendActions(for: .valueChanged)
            }
        }
    }
    
    //MARK:开始刷新
    func beginRefreshing() {
        guard let sv = scrollView else { return }
        
        if refreshView.refreshState == .WillRefresh {
            return
        }
        
        //设置刷新状态
        refreshView.refreshState = .WillRefresh
        
        //调整表格的间距
        //为了让刷新视图显示出来，需要修改表格的contentInset
        var inset = sv.contentInset
        inset.top += refreshOffset
        
        sv.contentInset = inset
        
    }
    
    //MARK:结束刷新
    func endRefreshing() {
        guard let sv = scrollView else { return }
        
        //只有正在刷新的才能结束刷新
        if refreshView.refreshState != .WillRefresh {
            return
        }
        
        //恢复刷新视图的状态
        refreshView.refreshState = .Normal
        
        //恢复表格的contentInset
        var inset = sv.contentInset
        inset.top -= refreshOffset
        sv.contentInset = inset
    }
}

extension MQLRefreshControl {
    func setUI() -> Void {
        backgroundColor = UIColor.orange
        
        //添加刷新视图
        self.addSubview(refreshView)
        
        //添加refreshView和self的自动布局约束
        refreshView.translatesAutoresizingMaskIntoConstraints = false
        
        let centerXConstraint = NSLayoutConstraint(item: refreshView,
                                                   attribute: .centerX,
                                                   relatedBy: .equal,
                                                   toItem: self,
                                                   attribute: .centerX,
                                                   multiplier: 1.0,
                                                   constant: 0.0)
        
        let bottomConstraint = NSLayoutConstraint(item: refreshView,
                                                   attribute: .bottom,
                                                   relatedBy: .equal,
                                                   toItem: self,
                                                   attribute: .bottom,
                                                   multiplier: 1.0,
                                                   constant: 0.0)
        
        let widthConstraint = NSLayoutConstraint(item: refreshView,
                                                 attribute: .width,
                                                 relatedBy: .equal,
                                                 toItem: nil,
                                                 attribute: .notAnAttribute,
                                                 multiplier: 1.0,
                                                 constant: refreshView.bounds.width)
        
        let heightConstraint = NSLayoutConstraint(item: refreshView,
                                                 attribute: .height,
                                                 relatedBy: .equal,
                                                 toItem: nil,
                                                 attribute: .notAnAttribute,
                                                 multiplier: 1.0,
                                                 constant: refreshView.bounds.height)
        
        self.addConstraints([centerXConstraint, bottomConstraint])
        refreshView.addConstraints([widthConstraint, heightConstraint])
        
    }
}











