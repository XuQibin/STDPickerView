//
//  STDAddressPickerView.h
//  STDPickerView
//
//  Created by XuQibin on 2018/3/9.
//  Copyright © 2018年 Standards. All rights reserved.
//

#import "STDPickerView.h"

#import "STDAddress.h"

@interface STDAddressPickerView : STDPickerView<STDPickerViewDelegate, STDPickerViewDataSource>

@property (strong, nonatomic, readonly) NSArray<STDAddressNode *> *selectedAddress;

@property (strong, nonatomic, readonly) NSString *selectedAddressString;

@property (copy, nonatomic) void(^didSelectAddress)(NSArray<STDAddressNode *> *selectedAddress, NSString *selectedAddressString);

- (STDAddressNode *)addressNodeAtComponent:(NSUInteger)component row:(NSUInteger)row;

@end
