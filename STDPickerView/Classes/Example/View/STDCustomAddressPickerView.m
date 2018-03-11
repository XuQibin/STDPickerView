//
//  STDCustomAddressPickerView.m
//  STDPickerView
//
//  Created by XuQibin on 2018/3/11.
//  Copyright © 2018年 Standards. All rights reserved.
//

#import "STDCustomAddressPickerView.h"

@implementation STDCustomAddressPickerView

- (UIView *)pickerView:(STDPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = (UILabel *)view;
    
    if (!label) {
        label = [[UILabel alloc] init];
        
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
    }
    
    label.textColor = kLightTextColor;
    label.transform = CGAffineTransformIdentity;
    label.text = [self addressNodeAtComponent:component row:row].name;
    
    return label;
}

#pragma mark - STDPickerViewDelegate
- (CGFloat)pickerView:(STDPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return self.forceItemTypeText ? 60 : 80;
}

- (void)pickerView:(STDPickerView *)pickerView willSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (self.forceItemTypeText) {
        return;
    }
    
    UILabel *label = (UILabel *)[pickerView viewForRow:row forComponent:component];
    
    [UIView animateWithDuration:0.25 animations:^{
        label.transform = CGAffineTransformMakeScale(1.2, 1.2);
    }];
    
    label.textColor = kGlobalColor;
    
    NSLog(@"willSelectRow %zd inComponent %zd",row,component);
}

- (void)pickerView:(STDPickerView *)pickerView willDeselectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (self.forceItemTypeText) {
        return;
    }
    
    UILabel *label = (UILabel *)[pickerView viewForRow:row forComponent:component];
    
    [UIView animateWithDuration:0.25 animations:^{
        label.transform = CGAffineTransformIdentity;
    }];
    
    label.textColor = kLightTextColor;
    
    NSLog(@"willDeselectRow %zd inComponent %zd",row,component);
}

- (UIView *)selectionIndicatorViewForPickerView:(STDPickerView *)pickerView
{
    UIView *view = [[UIView alloc] init];
    
    view.backgroundColor = kGlobalColorWithAlpha(0.3);
    
    view.layer.cornerRadius = 5;
    view.layer.masksToBounds = YES;
    
    return view;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
