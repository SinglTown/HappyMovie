//
//  TextEditView.m
//  Movie---Ceshi
//
//  Created by lanou3g on 16/1/18.
//  Copyright © 2016年 chuanbao. All rights reserved.
//

#import "TextEditView.h"

#define PASTER_SLIDE        200
#define FLEX_SLIDE          15.0
#define BT_SLIDE            30.0
#define BORDER_LINE_WIDTH   1.0
#define SECURITY_LENGTH     75.0

@interface TextEditView ()<UITextFieldDelegate>
{
    CGFloat minWidth;
    CGFloat minHeight;
    CGFloat deltaAngle;
    CGPoint prevPoint;
    CGPoint touchStart;
    CGRect  bgRect ;
}


@property (nonatomic,strong) UIImageView    *textDelete ;
@property (nonatomic,strong) UIImageView    *textSizeCtrl ;

//@property (nonatomic,strong)UITextField *myTextField;


@end

@implementation TextEditView

- (void)remove
{
    [self removeFromSuperview] ;
}

#pragma mark -- Initial
-(instancetype)initWithMyFrame:(CGRect)frame{
    self = [super init];
    if (self)
    {
        [self setupWithBGFrame:frame] ;
        [self myTextField] ;
        [self btDelete] ;
        [self btSizeCtrl] ;
        //关闭的用户交互,让底层的View响应
        self.myTextField.userInteractionEnabled = NO;
        self.myTextField.delegate = self;
        self.isOnFirst = YES ;
    }
    return self;
}
- (void)setFrame:(CGRect)newFrame
{
    [super setFrame:newFrame];
    
    CGRect rect = CGRectZero ;
    CGFloat sliderContent = PASTER_SLIDE - FLEX_SLIDE * 2 ;
    rect.origin = CGPointMake(FLEX_SLIDE, FLEX_SLIDE) ;
    rect.size = CGSizeMake(sliderContent, 30);
    self.myTextField.frame = rect ;
    self.myTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}


- (void)textSizeCtrlTranslate:(UIPanGestureRecognizer *)recognizer
{
    if ([recognizer state] == UIGestureRecognizerStateBegan)
    {
        prevPoint = [recognizer locationInView:self];
        [self setNeedsDisplay];
    }
    else if ([recognizer state] == UIGestureRecognizerStateChanged)
    {
        // preventing from the picture being shrinked too far by resizing
        if (self.bounds.size.width < minWidth || self.bounds.size.height < minHeight)
        {
            self.bounds = CGRectMake(self.bounds.origin.x,
                                     self.bounds.origin.y,
                                     minWidth + 1 ,
                                     minHeight + 1);
            self.btSizeCtrl.frame =CGRectMake(self.bounds.size.width-BT_SLIDE,
                                              self.bounds.size.height-BT_SLIDE,
                                              BT_SLIDE,
                                              BT_SLIDE);
            prevPoint = [recognizer locationInView:self];
        }
        // Resizing
        else
        {
            CGPoint point = [recognizer locationInView:self];
            float wChange = 0.0, hChange = 0.0;
            
            wChange = (point.x - prevPoint.x);
            float wRatioChange = (wChange/(float)self.bounds.size.width);
            
            hChange = wRatioChange * self.bounds.size.height;
            
            if (ABS(wChange) > 50.0f || ABS(hChange) > 50.0f)
            {
                prevPoint = [recognizer locationOfTouch:0 inView:self];
                return;
            }
            
            CGFloat finalWidth  = self.bounds.size.width + (wChange) ;
            CGFloat finalHeight = self.bounds.size.height + (wChange) ;
            
            if (finalWidth > PASTER_SLIDE*(1+0.5))
            {
                finalWidth = PASTER_SLIDE*(1+0.5) ;
            }
            if (finalWidth < PASTER_SLIDE*(1-0.5))
            {
                finalWidth = PASTER_SLIDE*(1-0.5) ;
            }
            if (finalHeight > PASTER_SLIDE*(1+0.5))
            {
                finalHeight = PASTER_SLIDE*(1+0.5) ;
            }
            if (finalHeight < PASTER_SLIDE*(1-0.5))
            {
                finalHeight = PASTER_SLIDE*(1-0.5) ;
            }
            
            self.bounds = CGRectMake(self.bounds.origin.x,
                                     self.bounds.origin.y,
                                     finalWidth,
                                     finalHeight) ;
            
            self.btSizeCtrl.frame = CGRectMake(self.bounds.size.width-BT_SLIDE  ,
                                               self.bounds.size.height-BT_SLIDE ,
                                               BT_SLIDE ,
                                               BT_SLIDE) ;
            
            prevPoint = [recognizer locationOfTouch:0
                                             inView:self] ;
        }
        
        /* Rotation */
        float ang = atan2([recognizer locationInView:self.superview].y - self.center.y,
                          [recognizer locationInView:self.superview].x - self.center.x) ;
        
        float angleDiff = deltaAngle - ang ;
        
        self.transform = CGAffineTransformMakeRotation(-angleDiff) ;
        
        [self setNeedsDisplay] ;
    }
    else if ([recognizer state] == UIGestureRecognizerStateEnded)
    {
        prevPoint = [recognizer locationInView:self];
        [self setNeedsDisplay];
    }
    self.myTextField.userInteractionEnabled = NO;
}
- (void)setupWithBGFrame:(CGRect)bgFrame
{
    CGRect rect = CGRectZero ;
    rect.size = CGSizeMake(PASTER_SLIDE, 60) ;
    self.frame = rect ;
    self.center = CGPointMake(bgFrame.size.width / 2, bgFrame.size.height / 2) ;
    self.backgroundColor = nil;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self addGestureRecognizer:tapGesture] ;
    
    
    UIRotationGestureRecognizer *rotateGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)] ;
    [self addGestureRecognizer:rotateGesture] ;
    
    self.userInteractionEnabled = YES ;
    
    minWidth   = self.bounds.size.width * 0.5;
    minHeight  = self.bounds.size.height * 0.5;
    
    deltaAngle = atan2(self.frame.origin.y+self.frame.size.height - self.center.y,
                       self.frame.origin.x+self.frame.size.width - self.center.x) ;
    
}

- (void)tap:(UITapGestureRecognizer *)tapGesture
{
    self.isOnFirst = YES ;
}

- (void)handlePinch:(UIPinchGestureRecognizer *)pinchGesture
{
    self.isOnFirst = YES ;
    
    self.myTextField.transform = CGAffineTransformScale(self.myTextField.transform,
                                                           pinchGesture.scale,
                                                           pinchGesture.scale) ;
    pinchGesture.scale = 1 ;
}

- (void)handleRotation:(UIRotationGestureRecognizer *)rotateGesture
{
    self.isOnFirst = YES ;
    
    self.transform = CGAffineTransformRotate(self.transform, rotateGesture.rotation) ;
    rotateGesture.rotation = 0 ;
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.myTextField.userInteractionEnabled = NO;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.myTextField.userInteractionEnabled = YES;
    
    self.isOnFirst = YES ;
    
    UITouch *touch = [touches anyObject] ;
    touchStart = [touch locationInView:self.superview] ;
    
}
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.myTextField.userInteractionEnabled = NO;
}
- (void)translateUsingTouchLocation:(CGPoint)touchPoint
{
    CGPoint newCenter = CGPointMake(self.center.x + touchPoint.x - touchStart.x,
                                    self.center.y + touchPoint.y - touchStart.y) ;
    
    // Ensure the translation won't cause the view to move offscreen. BEGIN
    //    CGFloat midPointX = CGRectGetMidX(self.bounds) ;
    if (newCenter.x > self.superview.bounds.size.width)
    {
        newCenter.x = self.superview.bounds.size.width;
    }
    if (newCenter.x < 0)
    {
        newCenter.x = 0;
    }
    
    //    CGFloat midPointY = CGRectGetMidY(self.bounds);
    if (newCenter.y > self.superview.bounds.size.height)
    {
        newCenter.y = self.superview.bounds.size.height;
    }
    if (newCenter.y < 0)
    {
        newCenter.y = 0;
    }
    
    // Ensure the translation won't cause the view to move offscreen. END
    self.center = newCenter;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(self.btSizeCtrl.frame, touchLocation)) {
        return;
    }
    
    CGPoint touch = [[touches anyObject] locationInView:self.superview];
    
    [self translateUsingTouchLocation:touch] ;
    
    touchStart = touch;
}
#pragma mark -- Properties
- (void)setIsOnFirst:(BOOL)isOnFirst
{
    _isOnFirst = isOnFirst ;
    
    self.btDelete.hidden = !isOnFirst ;
    self.btSizeCtrl.hidden = !isOnFirst ;
    self.myTextField.layer.borderWidth = isOnFirst ? BORDER_LINE_WIDTH : 0.0f ;
    
    if (isOnFirst)
    {
        
    }
}
- (UITextField *)myTextField
{
    if (!_myTextField)
    {
        CGRect rect = CGRectZero ;
        CGFloat sliderContent = PASTER_SLIDE - FLEX_SLIDE * 2 ;
        rect.origin = CGPointMake(FLEX_SLIDE, FLEX_SLIDE) ;
        rect.size = CGSizeMake(sliderContent, sliderContent) ;
        
        _myTextField = [[UITextField alloc] initWithFrame:rect];
        _myTextField.backgroundColor = [UIColor clearColor];
        _myTextField.layer.borderColor = [UIColor whiteColor].CGColor;
        _myTextField.layer.borderWidth = BORDER_LINE_WIDTH;
        _myTextField.placeholder = @"双击开始输入";
        [_myTextField setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
        _myTextField.textAlignment =  NSTextAlignmentCenter;
        _myTextField.contentMode = UIViewContentModeScaleAspectFit;
        
        
        
        if (![_myTextField superview])
        {
            [self addSubview:_myTextField] ;
        }
    }
    return _myTextField ;
}
- (UIImageView *)btSizeCtrl
{
    if (!_textSizeCtrl)
    {
        _textSizeCtrl = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width - BT_SLIDE  ,
                                                                   self.frame.size.height - BT_SLIDE ,
                                                                   BT_SLIDE ,
                                                                   BT_SLIDE)
                       ] ;
        _textSizeCtrl.userInteractionEnabled = YES;
        _textSizeCtrl.image = [UIImage imageNamed:@"iconfont-xuanzhuan.png"] ;
        
        UIPanGestureRecognizer *panResizeGesture = [[UIPanGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(textSizeCtrlTranslate:)] ;
        [_textSizeCtrl addGestureRecognizer:panResizeGesture] ;
        if (![_textSizeCtrl superview]) {
            [self addSubview:_textSizeCtrl] ;
        }
    }
    
    return _textSizeCtrl ;
}

- (UIImageView *)btDelete
{
    if (!_textDelete)
    {
        CGRect btRect = CGRectZero ;
        btRect.size = CGSizeMake(BT_SLIDE, BT_SLIDE) ;
        
        _textDelete = [[UIImageView alloc]initWithFrame:btRect] ;
        _textDelete.userInteractionEnabled = YES;
        _textDelete.image = [UIImage imageNamed:@"iconfont-shanchu.png"] ;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(textDeletePressed:)] ;
        [_textDelete addGestureRecognizer:tap] ;
        
        if (![_textDelete superview]) {
            [self addSubview:_textDelete] ;
        }
    }
    
    return _textDelete ;
}

- (void)textDeletePressed:(id)btDel
{
    [self remove] ;
}



@end
