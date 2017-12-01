//
//  DrawerColorPickerController.m
//  Drawing-Ceshi
//
//  Created by lanou3g on 16/1/19.
//  Copyright © 2016年 chuanbao. All rights reserved.
//

#import "DrawerColorPickerController.h"

@interface DrawerColorPickerController ()

@property (strong, nonatomic) IBOutlet UISlider *redColorSlider;
@property (strong, nonatomic) IBOutlet UISlider *greenColorSlider;
@property (strong, nonatomic) IBOutlet UISlider *blueColorSlider;
@property (strong, nonatomic) IBOutlet UISlider *alphaValueSlider;


@property (strong, nonatomic) IBOutlet UILabel *redColorValue;
@property (strong, nonatomic) IBOutlet UILabel *greenColorValue;
@property (strong, nonatomic) IBOutlet UILabel *blueColorValue;
@property (strong, nonatomic) IBOutlet UILabel *alphaValue;

@property (strong, nonatomic) IBOutlet UIImageView *resultColorImageView;


- (IBAction)redSliderMoved:(id)sender;
- (IBAction)greenSliderMoved:(id)sender;
- (IBAction)blueSliderMoved:(id)sender;
- (IBAction)alphaSliderMoved:(id)sender;


@end

@implementation DrawerColorPickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    const CGFloat *_components = CGColorGetComponents(self.currentSelectedColor.CGColor);
    CGFloat red     = _components[0];
    CGFloat green = _components[1];
    CGFloat blue   = _components[2];
    CGFloat alpha = _components[3];
    
    self.redColorSlider.value = red;
    self.greenColorSlider.value = green;
    self.blueColorSlider.value = blue;
    self.alphaValueSlider.value = alpha;
    
    [self.redColorValue setText:[NSString stringWithFormat:@"%.2f",red]];
    [self.greenColorValue setText:[NSString stringWithFormat:@"%.2f",green]];
    [self.blueColorValue setText:[NSString stringWithFormat:@"%.2f",blue]];
    [self.alphaValue setText:[NSString stringWithFormat:@"%.2f",alpha]];
    
    [self.resultColorImageView setBackgroundColor:self.currentSelectedColor];
    
//    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
//    self.navigationItem.leftBarButtonItem = leftItem;
    
}
#pragma mark - 点击Button回调
- (IBAction)confirmButtonClickAction:(id)sender {
    UIColor *color = self.resultColorImageView.backgroundColor;
    [self.delegate colorSelected:color];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Private methods
- (void)setResultColor
{
    CGFloat r = self.redColorSlider.value;
    CGFloat g = self.greenColorSlider.value;
    CGFloat b = self.blueColorSlider.value;
    CGFloat a = self.alphaValueSlider.value;
    
    [self.resultColorImageView setBackgroundColor:[UIColor colorWithRed:r green:g blue:b alpha:a]];
    
    [self.redColorValue setText:[NSString stringWithFormat:@"%.2f",r]];
    [self.greenColorValue setText:[NSString stringWithFormat:@"%.2f",g]];
    [self.blueColorValue setText:[NSString stringWithFormat:@"%.2f",b]];
    [self.alphaValue setText:[NSString stringWithFormat:@"%.2f",a]];
}
#pragma mark - Button action methods
- (IBAction)redSliderMoved:(id)sender {
     [self setResultColor];
}

- (IBAction)greenSliderMoved:(id)sender {
     [self setResultColor];
}

- (IBAction)blueSliderMoved:(id)sender {
     [self setResultColor];
}

- (IBAction)alphaSliderMoved:(id)sender {
     [self setResultColor];
}
@end
