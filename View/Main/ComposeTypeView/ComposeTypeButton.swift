//
//  ComposeTypeButton.swift
//  WeiBo
//
//  Created by QDHL on 2018/3/27.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

class ComposeTypeButton: UIControl {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    var clsName: String?
    
    class func initComposeTypeButtonFromNib(imageName: String, text: String) -> ComposeTypeButton {
        let nib = UINib(nibName: "ComposeTypeButton", bundle: nil)
        let button = nib.instantiate(withOwner: nil, options: nil)[0] as! ComposeTypeButton
        
        button.imageView.image = UIImage.init(named: imageName)
        button.titleLabel.text = text
        
        return button
    }
    
}
