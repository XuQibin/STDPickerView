//
//  STDPickerTextRenderView.m
//  STDPickerView
//
//  Created by XuQibin on 2017/10/26.
//  Copyright © 2017年 Standards. All rights reserved.
//

#import "STDPickerTextRenderView.h"

@interface STDPickerTextRenderView()

@property (strong, nonatomic) UILabel *unselectedLabel;
@property (strong, nonatomic) UILabel *selectedLabel;

@property (strong, nonatomic) CALayer *maskLayer;

@end

@implementation STDPickerTextRenderView

#pragma mark - initialization
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setupBaseConfig];
    }
    
    return self;
}

#pragma mark - setup
- (void)setupBaseConfig
{
    _font = [UIFont systemFontOfSize:14.0f];
    
    _textColor = [UIColor darkGrayColor];
    _selectedTextColor = [UIColor blackColor];
    _selectedTextDrawingRect = CGRectZero;
    _enableLineWrap = YES;
    
    [self setupTextLabel];
}

- (void)setupTextLabel
{
    _unselectedLabel = [[UILabel alloc] init];
    _unselectedLabel.textAlignment = NSTextAlignmentCenter;
    _unselectedLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_unselectedLabel];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[unselectedLabel]|" options:0 metrics:nil views:@{@"unselectedLabel":_unselectedLabel}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[unselectedLabel]|" options:0 metrics:nil views:@{@"unselectedLabel":_unselectedLabel}]];

    _selectedLabel = [[UILabel alloc] init];
    _selectedLabel.textAlignment = NSTextAlignmentCenter;
    _selectedLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_selectedLabel];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[selectedLabel]|" options:0 metrics:nil views:@{@"selectedLabel":_selectedLabel}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[selectedLabel]|" options:0 metrics:nil views:@{@"selectedLabel":_selectedLabel}]];
    
    _maskLayer = [[CALayer alloc] init];
    _maskLayer.backgroundColor = [[UIColor whiteColor] CGColor];
    _selectedLabel.layer.mask = _maskLayer;
    
    [self setupTextAttributes];
}

- (void)setupTextAttributes
{
    _unselectedLabel.textColor = _textColor;
    _unselectedLabel.font = _font;
    _unselectedLabel.numberOfLines = !_enableLineWrap;
    
    _selectedLabel.textColor = _selectedTextColor;
    _selectedLabel.font = _font;
    _selectedLabel.numberOfLines = !_enableLineWrap;
}

#pragma mark - setter and getter
- (void)setEnableLineWrap:(BOOL)enableLineWrap
{
    _enableLineWrap = enableLineWrap;
    
    [self setupTextAttributes];
}

- (void)setSelectedTextDrawingRect:(CGRect)selectedTextDrawingRect {
    _selectedTextDrawingRect = selectedTextDrawingRect;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _maskLayer.frame = selectedTextDrawingRect;
    [CATransaction commit];
}

- (void)setText:(NSString *)text
{
    _text = text;
    
    _unselectedLabel.text = text;
    _selectedLabel.text = text;
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    
    [self setupTextAttributes];
}

- (void)setSelectedTextColor:(UIColor *)selectedTextColor {
    _selectedTextColor = selectedTextColor;
    
    [self setupTextAttributes];
}

- (void)setFont:(UIFont *)font {
    _font = font;
    
    [self setupTextAttributes];
}

@end
