//
//  STDAddressPickerViewController.m
//  STDPickerView
//
//  Created by XuQibin on 2018/3/9.
//  Copyright © 2018年 Standards. All rights reserved.
//

#import "STDAddressPickerViewController.h"

@interface STDAddressPickerViewController ()

@property (strong, nonatomic) STDCustomAddressPickerView *pickerView;

@end

@implementation STDAddressPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupAddressPickerView];
}

#pragma mark - setup
- (void)setupAddressPickerView
{
    _pickerView = [[STDCustomAddressPickerView alloc] init];
    
    _pickerView.forceItemTypeText = _forceItemTypeText;
    _pickerView.selectionIndicatorStyle = _selectionIndicatorStyle;
    _pickerView.showVerticalDivisionLine = _showVerticalDivisionLine;

    _pickerView.textColor = kLightTextColor;
    _pickerView.selectedTextColor = kGlobalColor;
    _pickerView.font = [UIFont systemFontOfSize:17];
    
    if (_didSelectAddress) {
        _pickerView.didSelectAddress = _didSelectAddress;
    }
    
    _pickerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:_pickerView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[pickerView]|" options:0 metrics:nil views:@{@"pickerView":_pickerView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[pickerView]|" options:0 metrics:nil views:@{@"pickerView":_pickerView}]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
