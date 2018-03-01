//
//  ViewConstant.swift
//  WeiBo
//
//  Created by QDHL on 2018/1/10.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

//MARK: 屏幕宽度
func kScreenWidth() -> CGFloat {
    return UIScreen.main.bounds.width
}

//MARK: 屏幕高度
func kScreenHeight() -> CGFloat {
    return UIScreen.main.bounds.height
}

//MARK: 屏幕Bounds
func kScreenFrame() -> CGRect {
    return UIScreen.main.bounds
}

//MARK: 状态栏高度（20.f, iPhoneX下44.f）
func kStatusBarHeight() -> CGFloat {
    return UIApplication.shared.statusBarFrame.height
}

//MARK: 判断是否3.5英尺
let ThreeHalfInch   =  (kScreenWidth() * kScreenHeight() == 320.0 * 480.0) ? true : false

//MARK: 判断是否4英尺
let FourInch        = (kScreenWidth() * kScreenHeight() == 320.0 * 568.0) ? true : false

//MARK: 判断是否4.7 英寸
let FourSevenInch   = (kScreenWidth() * kScreenHeight() == 375.0 * 667.0) ? true : false

//MARK: 判断是否5.5英寸
let FiveFiveInch    = (kScreenWidth() * kScreenHeight() == 414.0 * 736.0) ? true : false

//MARK: 判断是否5.8英寸（iphone X）
let FiveEightInch = (kScreenWidth() * kScreenHeight() == 375.0 * 812.0) ? true : false

//MARK: tabBar的高度（iPhoneX下为83）
func kTabBarHeight() ->CGFloat{
    if kScreenWidth() > kScreenHeight() {//当前为横屏
        return FiveEightInch ? 53.0 : 49.0
    }else{//当前为竖屏
        return FiveEightInch ? 83.0 : 49.0
    }
}

//MARK: 导航栏高度
func kNavigationBarHeight() -> CGFloat {
    if kScreenWidth() > kScreenHeight() {//当前为横屏
        return FiveEightInch ? 32.0 : 44.0
    }else{//当前为竖屏
        return FiveEightInch ? 44.0 : 44.0
    }
}

//MARK: iPhoneX下，底部安全区域高度
func kBottomSafeAreaHeight() -> CGFloat {
    if kScreenWidth() > kScreenHeight() {//当前为横屏
        return FiveEightInch ? 21.0 : 0.0
    }else{//当前为竖屏
        return FiveEightInch ? 34.0 : 0.0
    }
}

//MARK: 相对于iPhone6(375 * 667)的比例--iPhone 6，也是目前psd设计图尺寸，比例一般用于图片的等比拉伸
//let ViewScaleX_375 = kScreenWidth / 375.0
func ViewScaleX_375() -> CGFloat {
    if kScreenWidth() > kScreenHeight() {//当前为横屏
        return kScreenWidth() / 667.0
    }else{//当前为竖屏
        return kScreenWidth() / 375.0
    }
}
//let ViewScaleY_667 = kScreenHeight / 667.0
func ViewScaleY_667() -> CGFloat {
    if kScreenWidth() > kScreenHeight() {//当前为横屏
        return kScreenHeight() / 375.0
    }else{//当前为竖屏
        return kScreenHeight() / 667.0
    }
}

//图片顶部间隔
let pictureTopMargin = CGFloat(12)

//图片间距
let pictureMargin = CGFloat(5.0)

//图片高度/宽度
let pictureWidth = (kScreenWidth() - CGFloat(12 * 2) - CGFloat(pictureMargin * 2)) / 3





