//
//  HorizontalPicker.m
//  HappyMovie
//
//  Created by lanou3g on 16/1/23.
//  Copyright © 2016年 刘培培. All rights reserved.
//

#import "HorizontalPicker.h"

@interface HorizontalPicker ()
@property (nonatomic) CGFloat currentSelectionX;
@end




@implementation HorizontalPicker

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.currentSelectionX = 0.0;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
-(void)drawRect:(CGRect)rect{

    // Drawing code
    [super drawRect:rect];

    //draw wings
    [[UIColor whiteColor] set];
    CGFloat tempXPlace = self.currentSelectionX;
    if (tempXPlace < 0.0) {
        tempXPlace = 0.0;
    } else if (tempXPlace >= self.frame.size.width) {
        tempXPlace = self.frame.size.width - 1.0;
    }
    CGRect temp = CGRectMake(0.0, tempXPlace,1.0 ,self.frame.size.height);
    UIRectFill(temp);
    
    //draw central bar over it
    CGFloat cbybegin = self.frame.size.height * 0.2;
    CGFloat cbheight = self.frame.size.height * 0.6;
    for (int x = 0; x < self.frame.size.width; x++) {
        [[UIColor colorWithHue:(x/self.frame.size.width) saturation:1.0 brightness:1.0 alpha:1.0] set];
        CGRect temp = CGRectMake(x, cbybegin, 1.0, cbheight);
        UIRectFill(temp);
    }
    
}
/*!
 Changes the selected color, updates the UI, and notifies the delegate.
 */
- (void)setSelectedColor:(UIColor *)selectedColor
{
    if (selectedColor != _selectedColor)
    {
        CGFloat hue = 0.0, temp = 0.0;
        if ([selectedColor getHue:&hue saturation:&temp brightness:&temp alpha:&temp])
        {
            self.currentSelectionX = floorf(hue * self.frame.size.width);
            [self setNeedsDisplay];
        }
        _selectedColor = selectedColor;
        
        if([self.delegate respondsToSelector:@selector(colorPicked:)])
        {
            [self.delegate colorPicked:_selectedColor];
        }
    }
}
#pragma amrk ======= 点击事件
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //update color
    self.currentSelectionX = [((UITouch *)[touches anyObject]) locationInView:self].x;
    _selectedColor = [UIColor colorWithHue:(self.currentSelectionX / self.frame.size.width) saturation:1.0 brightness:1.0 alpha:1.0];
    //notify delegate
    if([self.delegate respondsToSelector:@selector(colorPicked:)])
    {
        [self.delegate colorPicked:self.selectedColor];
    }
  
    
    [self setNeedsDisplay];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //update color
    self.currentSelectionX = [((UITouch *)[touches anyObject]) locationInView:self].x;
    _selectedColor = [UIColor colorWithHue:(self.currentSelectionX / self.frame.size.width) saturation:1.0 brightness:1.0 alpha:1.0];
    //notify delegate
    if([self.delegate respondsToSelector:@selector(colorPicked:)])
    {
        [self.delegate colorPicked:self.selectedColor];
    }
    [self setNeedsDisplay];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //update color
    self.currentSelectionX = [((UITouch *)[touches anyObject]) locationInView:self].x;
    _selectedColor = [UIColor colorWithHue:(self.currentSelectionX / self.frame.size.width) saturation:1.0 brightness:1.0 alpha:1.0];
    //notify delegate
    if([self.delegate respondsToSelector:@selector(colorPicked:)])
    {
        [self.delegate colorPicked:self.selectedColor];
    }
    [self setNeedsDisplay];
}


@end
