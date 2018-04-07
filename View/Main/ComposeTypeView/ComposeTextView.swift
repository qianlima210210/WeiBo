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


// MARK: - 表情插入、删除
extension ComposeTextView {
    /// 插入表情到文本视图
    ///
    /// - Parameter emotion: 表情对象
    func insertEmotion(emotion: Emotion?) -> Void {
        //1.删除按钮被点击
        guard let emotion = emotion else {
            deleteBackward()
            return
        }
        
        //2.emoj表情按钮被点击
        if let emojString = emotion.emojString, let range = selectedTextRange {
            replace(range, withText: emojString)
            return
        }
        
        //3.处理图文混排
        //3.1获取textView的属性文本
        let attrStrM = NSMutableAttributedString(attributedString: attributedText)
        
        //3.2将图片的属性文本插入到当前光标位置(先记录当前光标位置，插入后，重新设置光标位置)
        let selectedRange = self.selectedRange
        
        guard let font = font,
            let imageAttributeString = emotion.imageAttributeString(font: font) else {
                return
        }
        
        attrStrM.replaceCharacters(in: selectedRange, with:imageAttributeString)
        attributedText = attrStrM
        self.selectedRange = NSRange.init(location: selectedRange.location + imageAttributeString.length, length: 0)
        
        //因为赋值不会触发textViewDidChange，所以这里手动触发textViewDidChange
        delegate?.textViewDidChange?(self)
        
        //手动发送NSNotification.Name.UITextViewTextDidChange
        NotificationCenter.default.post(name: NSNotification.Name.UITextViewTextDidChange, object: self)
        
    }
}



