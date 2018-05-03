//
//  ComposeViewController.swift
//  WeiBo
//
//  Created by QDHL on 2018/3/28.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController {

    @IBOutlet weak var textView: ComposeTextView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    //MARK: 发布按钮
    var rightButton = UIButton(type: UIButtonType.system)
    
    //MARK: lazy只能和var一同使用；因为let需要初始值；
     lazy var emotionInputView: EmotionInputView = {
        return EmotionInputView.emotionInputView(){[weak self] (emotion: Emotion?) -> Void in
            self?.textView.insertEmotion(emotion: emotion)
        }
    }()
    
    //MARK: 记录系统键盘高度，供自己的inputView使用
    var heightOfSystemKeyBoard = CGFloat(0.0)
    
    @objc func exit() -> Void {
        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: 发布微博
    @objc func send() -> Void {
        let attributedText = textView.attributedText
        let text = EmotionsManager.emotionsManager.stringWithoutAttribute(attributeString: attributedText)
        
        
        //发布微博
        HttpEngine.httpEngine.publishWeiBo(text: text) { (dic:[String:Any]?, error: Error?) in
            //FIXME: 目前是403
        }
    }
    
    //MARK: 点击表情按钮
    @objc func emotionButtonClicked() {
        //当控件使用系统提供的键盘时，textView.inputView为nil
        //1.创建自己的inputView(x, y, width值任意)
        emotionInputView.frame = CGRect(x: 0.0, y: 0.0, width: 0.0, height: heightOfSystemKeyBoard)
        
        //2.赋值给textView
        textView.inputView = (textView.inputView == nil) ? emotionInputView : nil
        
        //3.加载显示
        textView.reloadInputViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        registerNotification()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //弹出键盘
        textView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //隐藏键盘
        textView.resignFirstResponder()
    }
    
    //MARK: 注册通知
    func registerNotification() -> Void {
        NotificationCenter.default.addObserver(self, selector: #selector(receivedNotification(n:)), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc func receivedNotification(n: Notification) -> Void {
        //获取键盘frame
        //获取键盘动画周期UIKeyboardAnimationDurationUserInfoKey
        guard let frame = (n.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = (n.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
            else{
                return
        }
        //记录系统键盘高度
        heightOfSystemKeyBoard = frame.height > CGFloat(0.0) ? frame.height : heightOfSystemKeyBoard
        
        //更新toolBar的bottomConstraint约束
        bottomConstraint.constant = view.frame.height - frame.minY
        
        //添加动画，让toolbar和键盘一起上下移动
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}


private extension ComposeViewController {
    func setupUI() -> Void {
        view.backgroundColor = .white
        setupNavigationBar()
        setupToolbar()
    }
    
    /// 设置工具栏
    func setupToolbar() -> Void {
        let itemSettings = [["normalImg":#imageLiteral(resourceName: "compose_toolbar_picture"), "highlightedImg":#imageLiteral(resourceName: "compose_toolbar_picture_highlighted")],
                            ["normalImg":#imageLiteral(resourceName: "compose_mentionbutton_background"), "highlightedImg":#imageLiteral(resourceName: "compose_mentionbutton_background_highlighted")],
                            ["normalImg":#imageLiteral(resourceName: "compose_trendbutton_background"), "highlightedImg":#imageLiteral(resourceName: "compose_trendbutton_background_highlighted")],
                            ["normalImg":#imageLiteral(resourceName: "compose_emoticonbutton_background"), "highlightedImg":#imageLiteral(resourceName: "compose_emoticonbutton_background_highlighted"), "actionName":"emotionButtonClicked"],
                            ["normalImg":#imageLiteral(resourceName: "compose_add_background"), "highlightedImg":#imageLiteral(resourceName: "compose_add_background_highlighted")]]
        
        var items = [UIBarButtonItem]()
        //遍历数组
        for item in itemSettings {
            let button = UIButton(type: .custom)
            button.setImage(item["normalImg"] as? UIImage, for: .normal)
            button.setImage(item["highlightedImg"] as? UIImage, for: .highlighted)
            if let actionName = item["actionName"] as? String {
                button.addTarget(self, action: Selector(actionName), for: .touchUpInside)
            }
            
            //添加UIBarButtonItem
            items.append(UIBarButtonItem(customView: button))
            
            //添加弹簧
            items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        }
        
        items.removeLast()
        toolBar.items =  items
    }
    
    // MARK: - 设置导航栏
    func setupNavigationBar() -> Void {
        //设置左边
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭",
                                                                style: .done,
                                                                target: self,
                                                                action: #selector(exit))
        
        
        //设置右边
        rightButton.addTarget(self, action: #selector(send), for: .touchUpInside)
        rightButton.frame = CGRect(x: 0, y: 0, width: 45, height: 30)
        rightButton.setTitle("发布", for: .normal)
        
        rightButton.setBackgroundImage(#imageLiteral(resourceName: "common_button_orange"), for: .normal)
        rightButton.setBackgroundImage(#imageLiteral(resourceName: "common_button_orange_highlighted"), for: .highlighted)
        rightButton.setBackgroundImage(#imageLiteral(resourceName: "common_button_white_disabled"), for: .disabled)
        
        rightButton.setTitleColor(UIColor.white, for: .normal)
        rightButton.setTitleColor(UIColor.lightGray, for: .disabled)

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        rightButton.isEnabled = false
        
        //设置中间
        navigationItem.titleView = titleLabel
        
    }
    
}

extension ComposeViewController : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView){
        rightButton.isEnabled = textView.hasText
    }
}
















