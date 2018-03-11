//
//  STDBasePickerViewController.m
//  STDPickerView
//
//  Created by XuQibin on 2017/10/30.
//  Copyright © 2017年 Standards. All rights reserved.
//

#import "STDBasePickerViewController.h"

@interface STDBasePickerViewController ()<STDPickerViewDataSource,STDPickerViewDelegate>

@property (strong, nonatomic) STDPickerView *pickerView;

@property (strong, nonatomic) NSArray<NSString *> *items;

@end

@implementation STDBasePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupPickerView];
}

#pragma mark - setter and getter
- (NSArray<NSString *> *)items
{
    if (!_items) {
        NSMutableArray *items = [NSMutableArray array];
        
        for (NSUInteger i = 0; i < 100; i++) {
            [items addObject:[NSString stringWithFormat:@"%.2zd",i]];
        }
        
        _items = items;
    }
    
    return _items;
}

#pragma mark - setup

- (void)setupPickerView
{
    _pickerView = [[STDPickerView alloc] init];
    
    _pickerView.dataSource = self;
    _pickerView.delegate = self;
    
    _pickerView.forceItemTypeText = _forceItemTypeText;
    
    _pickerView.selectionIndicatorStyle = _selectionIndicatorStyle;
    
    _pickerView.showVerticalDivisionLine = _showVerticalDivisionLine;
    
    _pickerView.edgeInsets = UIEdgeInsetsMake(0, 20, 0, 20);
    _pickerView.spacingOfComponents = 30;
    
    _pickerView.textColor = kLightTextColor;
    _pickerView.selectedTextColor = kGlobalColor;
    _pickerView.font = [UIFont systemFontOfSize:17];
    
    _pickerView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:_pickerView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[pickerView]|" options:0 metrics:nil views:@{@"pickerView":_pickerView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[pickerView]|" options:0 metrics:nil views:@{@"pickerView":_pickerView}]];
}

#pragma mark - STDPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(STDPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.items.count;
}

- (NSString *)pickerView:(STDPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.items[row];
}

- (UIView *)pickerView:(STDPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = (UILabel *)view;
    
    if (!label) {
        label = [[UILabel alloc] init];
        
        label.textAlignment = NSTextAlignmentCenter;
    }
    
    label.textColor = kLightTextColor;
    label.transform = CGAffineTransformIdentity;
    label.text = self.items[row];
    
    return label;
}

#pragma mark - STDPickerViewDelegate
- (CGFloat)pickerView:(STDPickerView *)pickerView widthRatioForComponent:(NSInteger)component
{
    return (CGFloat)(component + 1) / 3;
}

- (CGFloat)pickerView:(STDPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 60;
}

- (void)pickerView:(STDPickerView *)pickerView willSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (_forceItemTypeText) {
        return;
    }
    
    UILabel *label = (UILabel *)[pickerView viewForRow:row forComponent:component];
    
    [UIView animateWithDuration:0.25 animations:^{
        label.transform = CGAffineTransformMakeScale(1.5, 1.5);
    }];
    
    label.textColor = kGlobalColor;
    
    NSLog(@"willSelectRow %zd inComponent %zd",row,component);
}

- (void)pickerView:(STDPickerView *)pickerView willDeselectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (_forceItemTypeText) {
        return;
    }
    
    UILabel *label = (UILabel *)[pickerView viewForRow:row forComponent:component];
    
    [UIView animateWithDuration:0.25 animations:^{
        label.transform = CGAffineTransformIdentity;
    }];
    
    label.textColor = kLightTextColor;
    
    NSLog(@"willDeselectRow %zd inComponent %zd",row,component);
}

- (void)pickerView:(STDPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"Picker - didSelectRow %zd inComponent %zd", row, component);
    
    if (self.didSelectText) {
        self.didSelectText([NSString stringWithFormat:@"%@ - %@",self.items[[pickerView selectedRowInComponent:0]], self.items[[pickerView selectedRowInComponent:1]]]);
    }
}

- (UIView *)selectionIndicatorViewForPickerView:(STDPickerView *)pickerView
{
    UIView *view = [[UIView alloc] init];
    
    view.backgroundColor = kGlobalColorWithAlpha(0.3);
    
    view.layer.cornerRadius = 5;
    view.layer.masksToBounds = YES;
    
    return view;
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
