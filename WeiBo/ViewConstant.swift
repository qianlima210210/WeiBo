//
//  ViewConstant.swift
//  WeiBo
//
//  Created by QDHL on 2018/1/10.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

//MARK: 屏幕宽度
let kScreenWidth = UIScreen.main.bounds.width
//MARK: 屏幕高度
let kScreenHeight = UIScreen.main.bounds.height
//MARK: 屏幕Bounds
let kScreenFrame = UIScreen.main.bounds
//MARK: 状态栏高度（20.f, iPhoneX下44.f）
let kStatusBarHeight = UIApplication.shared.statusBarFrame.height

//MARK: 判断是否3.5英尺
let ThreeHalfInch =  (480 == kScreenHeight) ? true : false

//MARK: 判断是否4英尺
let FourInch  = (568 == kScreenHeight) ? true : false

//MARK: 判断是否4.7 英寸
let FourSevenInch = (667 == kScreenHeight) ? true : false

//MARK: 判断是否5.5英寸
let FiveFiveInch  = (736  == kScreenHeight) ? true : false

//MARK: 判断是否5.8英寸（iphone X）
let FiveEightInch = (812 == kScreenHeight) ? true : false

//MARK: tabBar的高度（iPhoneX下为83）
let kBYTabBarHeight: CGFloat = FiveEightInch ? 83.0 : 49.0

//MARK: 导航栏高度
let kNavigationBarHeight: CGFloat = 44.0

//MARK: iPhoneX下，底部安全区域高度
let kBottomSafeAreaHeight: CGFloat = 34.0

//MARK: 相对于iPhone6(375 * 667)的比例--iPhone 6，也是目前psd设计图尺寸，比例一般用于图片的等比拉伸
let ViewScaleX_375 = kScreenWidth / 375.0
let ViewScaleY_667 = kScreenHeight / 667.0




