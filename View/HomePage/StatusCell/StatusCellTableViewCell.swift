//
//  StatusCellTableViewCell.swift
//  WeiBo
//
//  Created by QDHL on 2018/2/24.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit
import SDWebImage

class StatusCellTableViewCell: UITableViewCell {

    @IBOutlet weak var touXiangImageView: UIImageView!
    @IBOutlet weak var screenName: UILabel!
    @IBOutlet weak var huiYuanImageView: UIImageView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var from: UILabel!
    @IBOutlet weak var renZhengImageView: UIImageView!
    @IBOutlet weak var zhengWen: UILabel!
    
    var status: WBStatus?{
        didSet{
            setZhengWen(text: status?.text ?? "")
            setScreenName(name: status?.user?.screen_name ?? "")
            setTouXiangImageView(status?.user?.profile_image_url)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /// 设置头像
    private func setTouXiangImageView(_ avatar_large: String?) -> Void {
        let url = URL(string: avatar_large ?? "")
        touXiangImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "avatar_large_userhead"), options: []) { (image, error, type, url) in
            
        }
    }
    
    /// 设置正文内容
    ///
    /// - Parameter text: 正文内容；这里没有直接在外部对zhengWen的text进行赋值的原因是，需要设置
    /// 正文标签的文本属性
    private func setZhengWen(text: String) -> Void {
        zhengWen.text = text
        //调整标签行间距
        let attributeText = NSMutableAttributedString(string: text)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5.0
        attributeText.addAttributes([NSAttributedStringKey.paragraphStyle:paragraphStyle],
                                    range: NSRange(location: 0, length: text.count))
        
        zhengWen.attributedText = attributeText
    }
    
    /// 设置昵称
    ///
    /// - Parameter name: 昵称
    private func setScreenName(name: String){
        screenName.text = name
    }

}

























