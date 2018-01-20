//
//  ContentOfVisitorView.swift
//  WeiBo
//
//  Created by QDHL on 2018/1/19.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

class ContentOfVisitorView: UIView {
    let margin: CGFloat = 20        //控件上下、左右间隔
    var selfWidth: CGFloat = 0      //本身宽度
    var selfHeight: CGFloat = 0     //本身高度
    
    var noteImageView = UIImageView()
    var noteLabel = UILabel()
    var registerBtn = UIButton()
    var logonBtn = UIButton()
    
    var sizeOfNoteImageView: CGSize = CGSize()
    var sizeOfNoteLabel: CGSize = CGSize()
    var sizeOfRegisterBtn: CGSize = CGSize()
    var sizeOfLogonBtn: CGSize = CGSize()
    
    var noteInfoDic:[String:Any]? {
        didSet{
            guard let image = noteInfoDic?["image"] as? UIImage,
                let noteText = noteInfoDic?["noteText"] as? String else{
                    return
            }
            
            //设置提示图片
            noteImageView.image = image
            
            //先设置sizeOfNoteLabel的属性字符串
            let range = NSRange(location: 0, length: noteText.count)
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 5.0;
            let attributes:[NSAttributedStringKey:NSObject] = [NSAttributedStringKey.font:noteLabel.font, NSAttributedStringKey.paragraphStyle:style]
            
            let attributeStr = NSMutableAttributedString(string: noteText)
            attributeStr.addAttributes(attributes, range: range)
            noteLabel.attributedText = attributeStr
            noteLabel.numberOfLines = 0
            noteLabel.textAlignment = .center
            
            //获取上面属性字符串高度
            sizeOfNoteLabel.height = noteText.heightOfString(size: sizeOfNoteLabel, font: noteLabel.font, lineSpacing: 5.0)
            
            registerBtn.setTitle("注册", for: .normal)
            registerBtn.setTitleColor(UIColor.orange, for: .normal)
            registerBtn.setTitleColor(UIColor.black, for: .highlighted)
            registerBtn.backgroundColor = UIColor.white
            registerBtn.layer.borderColor = UIColor.gray.cgColor
            registerBtn.layer.borderWidth = 1.0
            
            logonBtn.setTitle("登录", for: .normal)
            logonBtn.setTitleColor(UIColor.orange, for: .normal)
            logonBtn.setTitleColor(UIColor.black, for: .highlighted)
            logonBtn.backgroundColor = UIColor.white
            logonBtn.layer.borderColor = UIColor.gray.cgColor
            logonBtn.layer.borderWidth = 1.0
            
            //设置自身高度
            selfHeight = sizeOfNoteImageView.height + margin + sizeOfNoteLabel.height + margin + sizeOfRegisterBtn.height
        }
    }
    
    override init(frame: CGRect) {
        
        selfWidth = kScreenWidth() - margin * 2
        
        sizeOfNoteImageView = CGSize(width: 200, height: 100)
        sizeOfNoteLabel = CGSize(width: selfWidth, height: 0)
        sizeOfRegisterBtn = CGSize(width: (selfWidth - margin) / 2, height: 40)
        sizeOfLogonBtn = CGSize(width: (selfWidth - margin) / 2, height: 40)
        
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
    /// 设置提示信息
    func setNoteInfoDic(noteInfoDictionary:[String:Any]?) -> Void {
        
        noteInfoDic = noteInfoDictionary
        
        //添加控件
        self.addSubview(noteImageView)
        self.addSubview(noteLabel)
        self.addSubview(registerBtn)
        self.addSubview(logonBtn)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //设置坐标
        noteImageView.frame.origin.x = (selfWidth - sizeOfNoteImageView.width) / 2
        noteImageView.frame.origin.y = 0.0
        noteImageView.frame.size = sizeOfNoteImageView
        
        noteLabel.frame.origin.x = 0.0
        noteLabel.frame.origin.y = noteImageView.frame.origin.y + sizeOfNoteImageView.height + margin
        noteLabel.frame.size = sizeOfNoteLabel
        
        registerBtn.frame.origin.x = 0.0
        registerBtn.frame.origin.y = noteImageView.frame.origin.y + sizeOfNoteImageView.height + margin +
                                                                            sizeOfNoteLabel.height + margin
        registerBtn.frame.size = sizeOfRegisterBtn
        
        logonBtn.frame.origin.x = registerBtn.bounds.width + margin
        logonBtn.frame.origin.y = noteImageView.frame.origin.y + sizeOfNoteImageView.height + margin +
                                                                            sizeOfNoteLabel.height + margin
        logonBtn.frame.size = sizeOfLogonBtn
    }
    
}


















