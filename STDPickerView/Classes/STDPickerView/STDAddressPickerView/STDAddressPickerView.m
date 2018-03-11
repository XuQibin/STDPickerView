//
//  STDAddressPickerView.m
//  STDPickerView
//
//  Created by XuQibin on 2018/3/9.
//  Copyright © 2018年 Standards. All rights reserved.
//

#import "STDAddressPickerView.h"

@interface STDAddressPickerView()

@property (nonatomic, strong) STDAddress *address;

@property (assign, nonatomic) NSUInteger selectedProvinceIndex;
@property (assign, nonatomic) NSUInteger selectedCityIndex;
@property (assign, nonatomic) NSUInteger selectedCountyIndex;

@end


@implementation STDAddressPickerView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.delegate = self;
        self.dataSource = self;
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.delegate = self;
        self.dataSource = self;
    }
    
    return self;
}

#pragma mark - setter and getter
- (STDAddress *)address
{
    if (!_address) {
        _address = [STDAddress shareAddress];
    }
    
    return _address;
}

- (STDAddress *)selectedProvince
{
    if (self.address.children.count <= _selectedProvinceIndex) {
        return nil;
    }
    
    return self.address.children[_selectedProvinceIndex];
}

- (STDAddress *)selectedCity
{
    STDAddress *province = [self selectedProvince];
    
    if (province.children.count <= _selectedCityIndex) {
        return nil;
    }
    
    return province.children[_selectedCityIndex];
}

- (STDAddress *)selectedCounty
{
    STDAddress *city = [self selectedCity];
    
    if (city.children.count <= _selectedCountyIndex) {
        return nil;
    }
    
    return city.children[_selectedCountyIndex];
}

- (NSArray<STDAddressNode *> *)selectedAddress
{
    NSMutableArray *address = [NSMutableArray array];
    
    [address addObject:[self selectedProvince].node];
    
    for (NSUInteger i = 1; i < 3; i++) {
        
        if (i == 1) {
            if (![self selectedCity]) {
                break;
            }
            [address addObject:[self selectedCity].node];

        } else if (i == 2) {
            if (![self selectedCounty]) {
                break;
            }
            [address addObject:[self selectedCounty].node];
        }
    }
    
    return address;
}

- (NSString *)selectedAddressString
{
    NSMutableString *addressString = [NSMutableString string];
    
    [self.selectedAddress enumerateObjectsUsingBlock:^(STDAddressNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [addressString appendFormat:@"%@-",obj.name];
    }];
    
    return [[addressString substringToIndex:addressString.length - 1] copy];
}

#pragma mark - tools
- (STDAddressNode *)addressNodeAtComponent:(NSUInteger)component row:(NSUInteger)row
{
    STDAddressNode *addressNode = nil;
    
    if (component == 0) {
        addressNode = self.address.children[row].node;
    } else if (component == 1) {
        addressNode = [self selectedProvince].children[row].node;
    } else if (component == 2) {
        addressNode = [self selectedCity].children[row].node;
    }
    
    return addressNode;
}

#pragma mark - STDPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(STDPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return self.address.children.count;
    } else if (component == 1) {
        return [self selectedProvince].children.count;
    } else if (component == 2) {
        return [self selectedCity].children.count;
    }
    
    return 0;
}

- (NSString *)pickerView:(STDPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self addressNodeAtComponent:component row:row].name;
}

#pragma mark - STDPickerViewDelegate
- (void)pickerView:(STDPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    BOOL needToSelectAddress = NO;
    
    if (component == 0) {
        _selectedProvinceIndex = row;
        _selectedCityIndex = 0;
        _selectedCountyIndex = 0;
        
        [pickerView reloadComponent:1];
        [pickerView selectRow:0 inComponent:1 animated:YES];
        [pickerView reloadComponent:2];
        [pickerView selectRow:0 inComponent:2 animated:YES];
        
        needToSelectAddress = YES;
    } else if (component == 1) {
        NSUInteger selectedCityIndex = _selectedCityIndex;
        _selectedCityIndex = row;
        _selectedCountyIndex = 0;
        
        [pickerView reloadComponent:2];
        [pickerView selectRow:0 inComponent:2 animated:YES];
        
        needToSelectAddress = selectedCityIndex != row;
    } else {
        NSUInteger selectedCountyIndex = _selectedCountyIndex;
        _selectedCountyIndex = row;
        
        needToSelectAddress = selectedCountyIndex != row;
    }
    
    if (_didSelectAddress && needToSelectAddress) {
        _didSelectAddress(self.selectedAddress, self.selectedAddressString);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
