//
//  STDPickerTextRenderView.h
//  STDPickerView
//
//  Created by XuQibin on 2017/10/26.
//  Copyright © 2017年 Standards. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STDPickerTextRenderView : UIView

@property (nonatomic, copy) NSString *text;

@property (nonatomic, strong) UIFont *font;

@property (nonatomic, strong) UIColor *textColor; //default darkGrayColor
@property (nonatomic, strong) UIColor *selectedTextColor; //default blackColor

@property (nonatomic, assign) CGRect selectedTextDrawingRect;

@property (assign, nonatomic) BOOL enableLineWrap; //default YES

@end
