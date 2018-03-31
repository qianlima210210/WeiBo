//
//  BYChatLabel.m
//
//  Created by maqianli on 2018/3/13.
//  Copyright © 2018年 QDHL. All rights reserved.
//

#import "BYChatLabel.h"

@interface BYChatLabel()
//记录开始触摸点映射的内容范围
@property NSRange touchesBeganLocationMapRange;

//记录移动触摸点
@property CGPoint touchesMovedLocation;

//标记长按有效
@property BOOL longPressValid;

@end

@implementation BYChatLabel

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self != nil){
        [self initProperties];
        [self addObserverForAttributedText];
        [self prepareTextSystem];
    }
    return self;
}
    
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self != nil){
        [self initProperties];
        [self addObserverForAttributedText];
        [self prepareTextSystem];
    }
    return self;
}
    
-(void)initProperties{
    self.numberOfLines = 0;
    self.userInteractionEnabled = YES;    
    //self.backgroundColor = UIColor.orangeColor;
    
    _touchesBeganLocationMapRange = NSMakeRange(0, 0);
    
    _textStorage = [NSTextStorage new];
    _layoutManager = [NSLayoutManager new];
    _textContainer = [NSTextContainer new];
    
    _textContainer.lineFragmentPadding = 0;
}

-(BOOL)canBecomeFirstResponder{
    return true;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    return action == @selector(fuZhi) || action == @selector(quanXuan) || action == @selector(shouCang) ||
    action == @selector(shanChu) || action == @selector(tiXing) || action == @selector(duoXuan);
}

-(void)dealloc{
    [self removeObserver:self forKeyPath:@"attributedText"];
}
    
-(void)layoutSubviews{
    [super layoutSubviews];
    //指定绘制文本的区域
    _textContainer.size = self.bounds.size;
}
    
//绘制文本--TextKit接管底层实现，本质上是绘制NSTextStorage中的属性字符串
-(void)drawTextInRect:(CGRect)rect{
    NSRange range = NSMakeRange(0, _textStorage.length);
    
    //绘制背景颜色
    [_layoutManager drawBackgroundForGlyphRange:range atPoint:CGPointZero];
    
    //绘制glyphs
    [_layoutManager drawGlyphsForGlyphRange:range atPoint:CGPointZero];
}
    
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //先获取最后一个字符的位置
    CGRect lastCharFrame = [self characterRectAtIndex:_textStorage.length - 1];
    
    //获取触摸开始位置
    CGPoint point = [touches.anyObject locationInView:self];
    
    //触摸位置是否有效
    CGFloat maxX = lastCharFrame.origin.x + lastCharFrame.size.width;
    CGFloat maxY = lastCharFrame.origin.y + lastCharFrame.size.height;
    if(point.y > maxY){
        return;
    }else if (point.x > maxX && point.y > lastCharFrame.origin.y){
        return;
    }
    
    //启动计时1秒的操作，并把当前点作为_touchesMovedLocation起点
    [self performSelector:@selector(longPressOneSecodn) withObject:nil afterDelay:1.0];
    _touchesMovedLocation = point;
    
    //获取字形索引，并在字形索引范围定位
    NSUInteger index = [_layoutManager glyphIndexForPoint:point inTextContainer:_textContainer fractionOfDistanceThroughGlyph:nil];
    
    NSArray *ranges = [[[self urlRanges]arrayByAddingObjectsFromArray:[self phoneNumberRanges]]arrayByAddingObjectsFromArray:[self emailRanges]];
    
    for (NSDictionary *item in ranges) {
        CGFloat location = ((NSNumber*)[item objectForKey:@"location"]).floatValue;
        CGFloat length = ((NSNumber*)[item objectForKey:@"length"]).floatValue;
        NSRange range = NSMakeRange(location, length);
        
        if(NSLocationInRange(index, range)){
            [_textStorage addAttributes:@{NSForegroundColorAttributeName : UIColor.redColor} range:range];
            [self setNeedsDisplay];
            
            _touchesBeganLocationMapRange = range;
        }
    }
}

//按一秒
-(void)longPressOneSecodn {
    //防止在一秒前抬起
    if (_touchesMovedLocation.x == 0 && _touchesMovedLocation.y == 0){
        return;
    }
    
    //先判断_touchesMovedLocation是否在self内
    if ([self.layer containsPoint:_touchesMovedLocation]) {
        _longPressValid = YES;
        [self showMenu];
    }
}


/**
 显示菜单
 */
-(void)showMenu{
    [self becomeFirstResponder];
    NSArray *items = @[@"复制", @"全选", @"收藏", @"删除", @"提醒", @"多选"];
    UIMenuItem *fuZhi = [[UIMenuItem alloc]initWithTitle:items[0] action:@selector(fuZhi)];
    UIMenuItem *zhuanFa = [[UIMenuItem alloc]initWithTitle:items[1] action:@selector(quanXuan)];
    UIMenuItem *shouCang = [[UIMenuItem alloc]initWithTitle:items[2] action:@selector(shouCang)];
    UIMenuItem *shanChu = [[UIMenuItem alloc]initWithTitle:items[3] action:@selector(shanChu)];
    UIMenuItem *tiXing = [[UIMenuItem alloc]initWithTitle:items[4] action:@selector(tiXing)];
    UIMenuItem *duoXuan = [[UIMenuItem alloc]initWithTitle:items[5] action:@selector(duoXuan)];
    
    UIMenuController.sharedMenuController.menuItems = @[fuZhi, zhuanFa, shouCang, shanChu, tiXing, duoXuan];
    [UIMenuController.sharedMenuController setTargetRect:self.frame inView:self.superview];
    [UIMenuController.sharedMenuController setMenuVisible:YES animated:YES];
}

-(void)fuZhi{
}
-(void)quanXuan{
}
-(void)shouCang{
}
-(void)shanChu{
}
-(void)tiXing{
}
-(void)duoXuan{
}


-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    _touchesMovedLocation = [touches.anyObject locationInView:self];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //判断触摸开始是否有效
    if(NSEqualRanges(_touchesBeganLocationMapRange, NSMakeRange(0, 0)) == NO){
        //先恢复touchesBeganLocationMapRange显示状态
        [_textStorage addAttributes:@{NSForegroundColorAttributeName : UIColor.blueColor} range:_touchesBeganLocationMapRange];
        [self setNeedsDisplay];
    }
    
    if(_longPressValid){//长按已生效
        [self resetTouchBiaoJi];
    }else {//长按还未生效
        //取消长按定时perform
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(longPressOneSecodn) object:nil];
        
        //取消单击定时perform
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleDoubleTap:) object:nil];
        
        //获取点击对应索引
        CGPoint point = [touches.anyObject locationInView:self];
        
        if (touches.anyObject.tapCount == 1) {//单击
           [self performSelector:@selector(handleSingleTap:) withObject:[NSValue valueWithCGPoint:point] afterDelay:0.3];
        }else if (touches.anyObject.tapCount == 2){//双击
            [self handleDoubleTap:[NSValue valueWithCGPoint:point]];
        }
    }
    
}


//单击处理
-(void)handleSingleTap: (NSValue*)value{
    CGPoint point = value.CGPointValue;
    
    //先获取最后一个字符的位置
    CGRect lastCharFrame = [self characterRectAtIndex:_textStorage.length - 1];
    
    //触摸位置是否有效
    CGFloat maxX = lastCharFrame.origin.x + lastCharFrame.size.width;
    CGFloat maxY = lastCharFrame.origin.y + lastCharFrame.size.height;
    if((point.y > maxY) || (point.x > maxX && point.y > lastCharFrame.origin.y)){//无效点
        
    }else {
        NSUInteger index = [_layoutManager glyphIndexForPoint:point inTextContainer:_textContainer fractionOfDistanceThroughGlyph:nil];
        
        //判断是否url的点击
        NSArray *urlRanges = [self urlRanges];
        NSString *urlString = [self getValidClickedStringWithIndex:index ranges:urlRanges];
        if (urlString) {
            [self clickedType:BYURLClickedTypeOnChatLabel string:urlString];
        }
        
        //判断是否电话号码的点击
        NSArray *phoneNumberRanges = [self phoneNumberRanges];
        NSString *phoneNumberString = [self getValidClickedStringWithIndex:index ranges:phoneNumberRanges];
        if (phoneNumberString) {
            [self clickedType:BYPhoneNumClickedTypeOnChatLabel string:phoneNumberString];
        }
        
        //判断是否邮箱地址的点击
        NSArray *emailRanges = [self emailRanges];
        NSString *emailString = [self getValidClickedStringWithIndex:index ranges:emailRanges];
        if (emailString) {
            [self clickedType:BYEmailClickedTypeOnChatLabel string:emailString];
        }
    }
    
    [self resetTouchBiaoJi];
}

//双击击处理
-(void)handleDoubleTap: (NSValue*)value{
    NSLog(@"handleDoubleTap");
    [self resetTouchBiaoJi];
}

//恢复触摸标记
-(void)resetTouchBiaoJi{
    //最后恢复_touchesBeganLocationMapRange、_touchesBeganLocation、_longPressValid
    _touchesBeganLocationMapRange = NSMakeRange(0, 0);
    _touchesMovedLocation = CGPointZero;
    _longPressValid = NO;
}

//获取有效点击字符串
-(NSString*)getValidClickedStringWithIndex:(NSInteger)index ranges:(NSArray*)ranges {
    NSString *result = nil;
    
    for (NSDictionary *item in ranges) {
        CGFloat location = ((NSNumber*)[item objectForKey:@"location"]).floatValue;
        CGFloat length = ((NSNumber*)[item objectForKey:@"length"]).floatValue;
        NSRange range = NSMakeRange(location, length);
        
        if(NSLocationInRange(index, range)){
            if(NSEqualRanges(_touchesBeganLocationMapRange, range)){
                result = [_textStorage attributedSubstringFromRange:range].string;
            }
        }
    }
    
    return  result;
}

//处理有效点击
-(void)clickedType:(BYClickedTypeOnChatLabel)type string:(NSString*)string {
    switch (type) {
        case BYURLClickedTypeOnChatLabel:
            NSLog(@"您点击了url链接=%@", string);
            break;
        case BYPhoneNumClickedTypeOnChatLabel:
            NSLog(@"您点击了电话号码=%@", string);
            break;
        case BYEmailClickedTypeOnChatLabel:
            NSLog(@"您点击了邮箱地址=%@", string);
            break;
            
        default:
            break;
    }
}

//获取指定字形的位置范围
- (CGRect)characterRectAtIndex:(NSUInteger)charIndex
{
    if (charIndex >= _textStorage.length) {
        return CGRectZero;
    }
    NSRange characterRange = NSMakeRange(charIndex, 1);
    NSRange glyphRange = [self.layoutManager glyphRangeForCharacterRange:characterRange actualCharacterRange:nil];
    return [self.layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:self.textContainer];
}
    
 #pragma mark -- 观察attributedText变化
-(void)addObserverForAttributedText{
    [self addObserver:self forKeyPath:@"attributedText" options:NSKeyValueObservingOptionNew context:nil];
}
     
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"attributedText"]){
        [self prepareTextContent];
    }
}
    
#pragma mark -- 设置TextKit核心对象
//准备文本系统
-(void)prepareTextSystem {
    //准备文本内容
    [self prepareTextContent];
    
    //设置对象关系
    [_textStorage addLayoutManager:_layoutManager];
    [_layoutManager addTextContainer:_textContainer];
}
    
//准备文本内容
-(void)prepareTextContent {
    if(self.attributedText != nil){
        [_textStorage setAttributedString:self.attributedText];
    }else if(self.text != nil){
        NSAttributedString *attributedString = [[NSAttributedString alloc]initWithString:self.text];
        [_textStorage setAttributedString:attributedString];
    }else{
        NSAttributedString *attributedString = [[NSAttributedString alloc]initWithString:@""];
        [_textStorage setAttributedString:attributedString];
    }
    
    //设置URL、电话、邮箱颜色及背景颜色
    NSArray *ranges = [[[self urlRanges] arrayByAddingObjectsFromArray:[self phoneNumberRanges]] arrayByAddingObjectsFromArray:[self emailRanges]];
    
    for (NSDictionary *item in ranges) {
        CGFloat location = ((NSNumber*)[item objectForKey:@"location"]).floatValue;
        CGFloat length = ((NSNumber*)[item objectForKey:@"length"]).floatValue;
        NSRange range = NSMakeRange(location, length);
        
        [_textStorage addAttributes:@{NSForegroundColorAttributeName : UIColor.blueColor} range:range];
    }
}
    
#pragma mark -- 正则表达式处理
//根据正则表达式获取_textStorage.string中的网址范围数组
-(NSArray*)urlRanges {
    //设置正则表达式
    NSString *pattern = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSRegularExpression *regx = [[NSRegularExpression alloc]initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    
    //匹配所有项
    NSRange range = NSMakeRange(0, _textStorage.string.length);
    NSArray *matches = [regx matchesInString:_textStorage.string options:NSMatchingReportProgress range:range];
    
    //遍历所有适配结果
    NSMutableArray *ranges = [NSMutableArray array];
    
    for (NSTextCheckingResult *item in matches) {
        [ranges addObject:@{@"location": [NSNumber numberWithFloat:item.range.location], @"length":[NSNumber numberWithFloat:item.range.length]}];
    }
    
    return ranges;
}

//根据正则表达式获取_textStorage.string中的手机号码范围数组
-(NSArray*)phoneNumberRanges {
    //设置正则表达式
    NSString *pattern = @"\\d{3,4}[- ]?\\d{7,8}";
    NSRegularExpression *regx = [[NSRegularExpression alloc]initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    
    //匹配所有项
    NSRange range = NSMakeRange(0, _textStorage.string.length);
    NSArray *matches = [regx matchesInString:_textStorage.string options:NSMatchingReportProgress range:range];
    
    //遍历所有适配结果
    NSMutableArray *ranges = [NSMutableArray array];
    
    for (NSTextCheckingResult *item in matches) {
        [ranges addObject:@{@"location": [NSNumber numberWithFloat:item.range.location], @"length":[NSNumber numberWithFloat:item.range.length]}];
    }
    
    return ranges;
}

//根据正则表达式获取_textStorage.string中的email范围数组
-(NSArray*)emailRanges {
    //设置正则表达式
    NSString *pattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSRegularExpression *regx = [[NSRegularExpression alloc]initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    
    //匹配所有项
    NSRange range = NSMakeRange(0, _textStorage.string.length);
    NSArray *matches = [regx matchesInString:_textStorage.string options:NSMatchingReportProgress range:range];
    
    //遍历所有适配结果
    NSMutableArray *ranges = [NSMutableArray array];
    
    for (NSTextCheckingResult *item in matches) {
        [ranges addObject:@{@"location": [NSNumber numberWithFloat:item.range.location], @"length":[NSNumber numberWithFloat:item.range.length]}];
    }
    
    return ranges;
}

@end

























