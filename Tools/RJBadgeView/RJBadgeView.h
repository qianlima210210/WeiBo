//
//  RJBadgeView.h
//  RJBadgeKit
//
//  Created by Ryan Jin on 04/08/2017.
//
//

#import <UIKit/UIKit.h>

/**
 priority: number > custom view > red dot
 */

@protocol RJBadgeView <NSObject>

@required

@property (nonatomic, strong) UILabel *badge;
@property (nonatomic, strong) UIFont  *badgeFont;      // default bold size 9
@property (nonatomic, strong) UIColor *badgeTextColor; // default white color
@property (nonatomic, assign) CGFloat badgeRadius;
@property (nonatomic, assign) CGPoint badgeOffset;     // offset from right-top

- (void)showBadge; // badge with red dot
- (void)hideBadge;

// badge with number, pass zero to hide badge
- (void)showBadgeWithValue:(NSUInteger)value;


@end
