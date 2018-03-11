//
//  STDAddressPickerViewController.h
//  STDPickerView
//
//  Created by XuQibin on 2018/3/9.
//  Copyright © 2018年 Standards. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "STDCustomAddressPickerView.h"

@interface STDAddressPickerViewController : UIViewController

@property (assign, nonatomic) BOOL forceItemTypeText;

@property(assign, nonatomic) BOOL showVerticalDivisionLine;

@property (assign, nonatomic) STDPickerViewSelectionIndicatorStyle                       selectionIndicatorStyle;

@property (copy, nonatomic) void(^didSelectAddress)(NSArray<STDAddressNode *> *selectedAddress, NSString *selectedAddressString);

@end
