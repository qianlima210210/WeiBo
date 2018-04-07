//
//  ViewController.swift
//  表情键盘
//
//  Created by QDHL on 2018/4/3.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    /// lazy只能和var一同使用；因为let需要初始值；
    lazy var emotionInputView: EmotionInputView = {
        return EmotionInputView.emotionInputView(){[weak self] (emotion: Emotion?) -> Void in
        self?.insertEmotion(emotion: emotion)
        }
    }()
    
    /// 插入表情到文本视图
    ///
    /// - Parameter emotion: 表情对象
    func insertEmotion(emotion: Emotion?) -> Void {
        //1.删除按钮被点击
        guard let emotion = emotion else {
            textView.deleteBackward()
            return
        }
        
        //2.emoj表情按钮被点击
        if let emojString = emotion.emojString, let range = textView.selectedTextRange {
            textView.replace(range, withText: emojString)
            return
        }
        
        //3.处理图文混排
        //3.1获取textView的属性文本
        let attrStrM = NSMutableAttributedString(attributedString: textView.attributedText)
        
        //3.2将图片的属性文本插入到当前光标位置(先记录当前光标位置，插入后，重新设置光标位置)
        let selectedRange = textView.selectedRange
        
        guard let font = textView.font,
         let imageAttributeString = emotion.imageAttributeString(font: font) else {
            return
        }
        
        attrStrM.replaceCharacters(in: selectedRange, with:imageAttributeString)
        textView.attributedText = attrStrM
        textView.selectedRange = NSRange.init(location: selectedRange.location + imageAttributeString.length, length: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        textView.textAlignment = .left
        textView.contentInsetAdjustmentBehavior = .never
        textView.textContainer.lineFragmentPadding = 0.0
        textView.textContainerInset = UIEdgeInsets.zero
    
        textView.inputView = emotionInputView
        textView.reloadInputViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textView.becomeFirstResponder()
    }
    
    @IBAction func show(_ sender: UIBarButtonItem) {
        print(EmotionsManager.emotionsManager.stringWithoutAttribute(attributeString: textView.attributedText))
    }

}

extension ViewController : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        print(textView.text)
    }
}







