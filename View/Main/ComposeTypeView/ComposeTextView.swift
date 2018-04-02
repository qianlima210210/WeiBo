//
//  ComposeTextView.swift
//  WeiBo
//
//  Created by QDHL on 2018/4/2.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

class ComposeTextView: UITextView {
    
    var placeholderLabel: UILabel = UILabel()

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        registerNotification()
    }
    
    @objc func onReceivedNotification(n: Notification) -> Void {
        //有内容时隐藏站位标签；否则显示站位标签
        placeholderLabel.isHidden = hasText
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

private extension ComposeTextView {
    
    /// 设置用户界面
    func setupUI() -> Void {
        placeholderLabel.text = "分享新鲜事..."
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.font = self.font
        placeholderLabel.sizeToFit()
        placeholderLabel.frame.origin = CGPoint(x: 5.0, y: 8.0)
        
        self.addSubview(placeholderLabel)
    }
    
    /// 注册通知
    func registerNotification() -> Void {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onReceivedNotification(n:)),
                                               name: NSNotification.Name.UITextViewTextDidChange,
                                               object: self)
    }
}




