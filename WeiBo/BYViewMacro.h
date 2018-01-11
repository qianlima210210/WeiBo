//
//  BYViewMacro.h
//
//
//  Created by zhoucy on 15/12/1.
//  Copyright © 2015年 www.qdingnet.com. All rights reserved.
//

#ifndef BYViewMacro_h
#define BYViewMacro_h


// 1.
// 屏幕宽度
#define kBYScreenWidth          ([[UIScreen mainScreen] bounds].size.width)
// 屏幕高度
#define kBYScreenHeight         ([[UIScreen mainScreen] bounds].size.height)
// 屏幕Bounds
#define kBYScreenFrame          (CGRectMake(0, 0 ,kBYScreenWidth,kBYScreenHeight))
// 状态栏高度（20.f, iPhoneX下44.f）
#define kBYStatusBarHeight      ([[UIApplication sharedApplication] statusBarFrame].size.height)
#define kBYApplicationHeight    (kBYScreenHeight - kBYStatusBarHeight)

// 判断是否3.5英尺
#define BYThreeHalfInch (480 == kBYScreenHeight)
#define BYThreeHalfInchScreenWidth 320

// 判断是否4英尺
#define BYFourInch (568 == kBYScreenHeight)
#define BYFourInchScreenWidth 320

//4.7 英寸
#define BYFourSevenInch (667 == kBYScreenHeight)
#define BYFourSevenInchScreenWidth 375
#define BYFourSevenInchScreenHeight 667

//5.5英寸
#define BYFiveFiveInch (736  == kBYScreenHeight)

// 5.8英寸（iphone X）
#define BYFiveEightInch (812 == kBYScreenHeight)

// tabBar的高度（iPhoneX下为83）
#define kBYTabBarHeight   (BYFiveEightInch ? 83.f : 49.0f)

// 导航栏高度
#define kBYNavigationBarHeight  44.0f

// iPhoneX下，底部安全区域高度
#define kBYBottomSafeAreaHeight 34.f


// 相对于(320 * 568)的比例--iPhone 5s
#define BYViewScaleX (kBYScreenWidth / 320.f)
#define BYViewScaleY (BYThreeHalfInch ? 1 : (kBYScreenHeight / 568.0f))

#define BYViewScaleX_320    (kBYScreenWidth / 320.f)
#define BYViewScaleY_320    (BYThreeHalfInch ? 1 : (kBYScreenHeight / 480.0f))

#pragma mark - iPhone 6
//相对于iPhone6(375 * 667)的比例
#define BYViewScaleX_375    (kBYScreenWidth / 375.f)
#define BYViewScaleY_375    BYViewScaleX_375
#define BYViewScaleY_667    (BYFourSevenInch ? 1 : (kBYScreenHeight / 667.f))

#define BYViewScaleN    BYViewScaleX_375

#define BYScaleRectMakeN(x, y, w, h) \
CGRectMake((x) * BYViewScaleN, (y) * BYViewScaleN, (w) * BYViewScaleN, (h) * BYViewScaleN)

#define BYScaleRectMakeWithRectN(r)  \
BYScaleRectMakeN(r.origin.x, r.origin.y, r.size.width, r.size.height)


#pragma mark - iPhone 5s
// 相对于(320 * 568)的rect和size
#define BYScaleRectMake(x, y, w, h) \
CGRectMake((x) * BYViewScaleX, (y) * BYViewScaleY, (w) * BYViewScaleX, (h) * BYViewScaleY)

#define BYScaleRectMakeWithRect(r)  \
BYScaleRectMake(r.origin.x, r.origin.y, r.size.width, r.size.height)

#define BYScaleSizeMake(w, h)       \
CGSizeMake((w) * BYViewScaleX, (h) * BYViewScaleY)
#define BYScalePointMake(x, y)      \
CGPointMake((x) * BYViewScaleX, (y) * BYViewScaleY)



#endif /* BYViewMacro_h */
