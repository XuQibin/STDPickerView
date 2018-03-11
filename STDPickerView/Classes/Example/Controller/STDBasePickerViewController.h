//
//  STDBasePickerViewController.h
//  STDPickerView
//
//  Created by XuQibin on 2017/10/30.
//  Copyright © 2017年 Standards. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "STDPickerView.h"

@interface STDBasePickerViewController : UIViewController

@property (assign, nonatomic) BOOL forceItemTypeText;

@property(assign, nonatomic) STDPickerViewSelectionIndicatorStyle                       selectionIndicatorStyle;

@property(assign, nonatomic) BOOL showVerticalDivisionLine;

@property (assign, nonatomic) NSUInteger selectedIndex;

@property (copy, nonatomic) void(^didSelectText)(NSString *selectedText);

@end
