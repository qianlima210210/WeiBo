//
//  StatusCellTableViewCell.swift
//  WeiBo
//
//  Created by QDHL on 2018/2/24.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit
import SDWebImage

@objc protocol StatusCellTableViewCellDelegate : NSObjectProtocol {
    @objc optional func statusCellTableViewCellURLClicked(cell: StatusCellTableViewCell?, string: String?)
    @objc optional func statusCellTableViewCellPhoneNumClicked(cell: StatusCellTableViewCell?, string: String?)
    @objc optional func statusCellTableViewCellEmailClicked(cell: StatusCellTableViewCell?, string: String?)
}

class StatusCellTableViewCell: UITableViewCell {
    
    weak var delegate: StatusCellTableViewCellDelegate?

    @IBOutlet weak var touXiangImageView: UIImageView!
    @IBOutlet weak var screenName: UILabel!
    @IBOutlet weak var huiYuanImageView: UIImageView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var from: UILabel!
    @IBOutlet weak var renZhengImageView: UIImageView!
    
    @IBOutlet weak var zhengWen: BYChatLabel!
    @IBOutlet weak var zhengWenHeight: NSLayoutConstraint!
    
    @IBOutlet weak var pictureViewHeight: NSLayoutConstraint!
    @IBOutlet weak var pictureContainerView: PictureContainerView!
    
    @IBOutlet weak var zhuanFaBtnWidth: NSLayoutConstraint!
    @IBOutlet weak var zhuanFaBtn: UIButton!
    @IBOutlet weak var pingLunBtn: UIButton!
    @IBOutlet weak var dianZhanBtn: UIButton!
    
    //被转发的微博的正文标签
    @IBOutlet weak var retweetedZhenWen: BYChatLabel?
    
    @IBOutlet weak var retweetedZhengWenHeight: NSLayoutConstraint?
    
    var statusViewModel: WBStatusViewModel?{
        didSet{
            setZhengWen()
            setRetweetedZhenWen()
            
            setScreenName(name: statusViewModel?.status?.user?.screen_name ?? "")
            setTouXiangImageView(statusViewModel?.status?.user?.profile_image_url)
            setHuiYuanImageView(mbrank: statusViewModel?.status?.user?.mbrank)
            setRenZhengImageView(verified_type: statusViewModel?.status?.user?.verified_type)
            setCreateTime(time: statusViewModel?.status?.created_at ?? "")
            setFrom(from: statusViewModel?.status?.source ?? "")
            
            setPictureViewHeight()
            
            zhuanFaBtn.setTitle(getZhuanFaPingLunZanTitle(count: statusViewModel?.status?.reposts_count ?? 0, defaultTitle: " 转发"),
                                for: .normal)
            pingLunBtn.setTitle(getZhuanFaPingLunZanTitle(count: statusViewModel?.status?.comments_count ?? 0, defaultTitle: " 评论"),
                                for: .normal)
            dianZhanBtn.setTitle(getZhuanFaPingLunZanTitle(count: statusViewModel?.status?.attitudes_count ?? 0, defaultTitle: " 点赞"),
                                for: .normal)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //离屏渲染
        self.layer.drawsAsynchronously = true
        
        //栅格化
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        
        // Initialization code
        zhuanFaBtnWidth.constant = (kScreenWidth() - 12 * 2 ) / 3.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//MARK: 头像、正文、昵称、会员、认证类型
extension StatusCellTableViewCell{
    /// 设置头像
    private func setTouXiangImageView(_ avatar_large: String?) -> Void {
        let url = URL(string: avatar_large ?? "")
        touXiangImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "avatar_large_userhead"), options: []) { (image, error, type, url) in
            if let image = image {
                self.touXiangImageView.image = image.imageWithoutColorMisaligned(
                    size: self.touXiangImageView.bounds.size,
                    backColor: self.backgroundColor)
            }
        }
    }
    
    /// 设置正文内容
    ///
    /// - Parameter text: 正文内容；这里没有直接在外部对zhengWen的text进行赋值的原因是，需要设置
    /// 正文标签的文本属性
    private func setZhengWen() -> Void {
        zhengWen.delegate = self
        
        zhengWen.attributedText = statusViewModel?.attrText
        zhengWenHeight.constant = statusViewModel?.attrText?.heightOfString(size: CGSize(width: kScreenWidth() - CGFloat(12 * 2),
                                                                            height: CGFloat(1000.0)),
                                                                            font: UIFont.systemFont(ofSize: 13),
                                                                            lineSpacing: 5.0) ?? CGFloat(0.0)
    }
    
    /// 设置昵称
    ///
    /// - Parameter name: 昵称
    private func setScreenName(name: String){
        screenName.text = name
    }
    
    /// 设置会员图标
    ///
    /// - Parameter image:
    private func setHuiYuanImageView(mbrank: Int?){
        
        guard let mbrank = mbrank else {
            return
        }
        var imageName = "huaiYuan"
        if mbrank > 0 &&  mbrank < 7 {
            imageName = imageName + "\(mbrank)"
        }
        let memberIcon = UIImage(named: imageName)
        huiYuanImageView.image = memberIcon
    }
    
    
    /// 设置创建时间
    /// - Parameter time: 时间字符串
    func setCreateTime(time: String?) -> Void {
        // FIXME: ......
//        guard let time = time else { return }
//
//        //先转成Date
//        let formatter0 = DateFormatter()
//        formatter0.dateStyle = .full
//        formatter0.timeStyle = .full
//        let timeZone = TimeZone.autoupdatingCurrent
//        formatter0.timeZone = timeZone
//        guard let date = formatter0.date(from: time) else {
//            return
//        }
//
//        //再转成想要的字符串
//        let formatter1 = DateFormatter()
//        formatter1.dateFormat = "yyyy-MM-dd HH:mm:ss"
//
//        self.time.text = formatter1.string(from: date)
    }
    
    
    /// 设置来源
    ///
    /// - Parameter from: 来源字符串
    func setFrom(from: String?) -> Void {
        self.from.text = statusViewModel?.sourceFrom
    }
    
    /// 设置认证类型
    ///
    /// - Parameter verified_type:
    private func setRenZhengImageView(verified_type: Int?){
        guard let verified_type = verified_type else {
            return
        }
        var imageName = ""
        switch verified_type {
        case 0:
            imageName = "yongHuRenZheng"
        case 2, 3, 5:
            imageName = "qiYeRenZheng"
        case 220:
            imageName = "daRenRenZheng"
        default:
            break
        }
        let renZhengIcon = UIImage(named:imageName)
        renZhengImageView.image = renZhengIcon
    }
}


//MARK: 图片视图
extension StatusCellTableViewCell {
    //设置图片视图高度
    private func setPictureViewHeight() -> Void {
        pictureContainerView.vm = statusViewModel
        pictureViewHeight.constant = statusViewModel?.prictureViewSize.height ?? 0
    }
}

//MARK: 转发/评论/点赞
extension StatusCellTableViewCell {
    
    /// 获取转发/评论/赞个数
    ///
    /// - Parameters:
    ///   - count: 个数
    ///   - defaultTitle: 默认标题
    /// - Returns:转发/评论/赞个数
    func getZhuanFaPingLunZanTitle(count: Int, defaultTitle:String) -> String {
        
        if count == 0 {
            return defaultTitle
        }
            
        if count < 10000 {
            return " \(count)"
        }
        
        if count > 10000 {
            return String.init(format: " %.2f万", CGFloat(count) / 10000)
        }
        
        return defaultTitle
    }
    
    @IBAction func zhuanFaBtnClicked(_ sender: UIButton) {
        
    }
    
    @IBAction func dianZhanBtnClicked(_ sender: UIButton) {
        
    }
    
    @IBAction func pingLunBtnClicked(_ sender: UIButton) {
        
    }
}

//被转发的正文
extension StatusCellTableViewCell {
    //设置被转发微博的正文
    private func setRetweetedZhenWen() -> Void {
        retweetedZhenWen?.delegate = self
        
        retweetedZhenWen?.attributedText = statusViewModel?.retweetedAttrText
        retweetedZhengWenHeight?.constant = statusViewModel?.retweetedAttrText?.heightOfString(size: CGSize(width: kScreenWidth() - CGFloat(12 * 2),
                                                                                         height: CGFloat(1000.0)),
                                                                            font: UIFont.systemFont(ofSize: 12),
                                                                            lineSpacing: 5.0) ?? CGFloat(0.0)
        
    }
}

@objc extension StatusCellTableViewCell : BYChatLabelDelegate {
    func chatLabelURLClicked(_ chatLabel: BYChatLabel?, string: String?) {
        delegate?.statusCellTableViewCellURLClicked?(cell: self, string: string)
    }
    
    func chatLabelPhoneNumClicked(_ chatLabel: BYChatLabel?, string: String?) {
        delegate?.statusCellTableViewCellPhoneNumClicked?(cell: self, string: string)
    }
    
    func chatLabelEmailClicked(_ chatLabel: BYChatLabel?, string: String?) {
        delegate?.statusCellTableViewCellEmailClicked?(cell: self, string: string)
    }
}


















