//
//  STDAddress.h
//  STDPickerView
//
//  Created by XuQibin on 2017/10/27.
//  Copyright © 2017年 Standards. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STDAddressNode : NSObject

@property (copy, nonatomic) NSString *ID; //区位码
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *pid; //父节点区位码

@end

@interface STDAddress : NSObject

@property (strong, nonatomic) STDAddressNode *node;

@property (copy, nonatomic) NSArray<STDAddress *> *children;

+ (instancetype)shareAddress;

@end
