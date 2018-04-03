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
    let emotionInputView: EmotionInputView = EmotionInputView.emotionInputView()
    
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


}

