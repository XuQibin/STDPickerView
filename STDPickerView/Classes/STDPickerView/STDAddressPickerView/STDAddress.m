//
//  STDAddress.m
//  STDPickerView
//
//  Created by XuQibin on 2017/10/27.
//  Copyright © 2017年 Standards. All rights reserved.
//

#import "STDAddress.h"

@implementation STDAddressNode

+ (instancetype)nodeWithDictionary:(NSDictionary *)dict
{
    STDAddressNode *node = [[STDAddressNode alloc] init];
    
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    
    [mutableDict setValue:dict[@"id"] forKey:@"ID"];
    [mutableDict removeObjectForKey:@"id"];
    
    [node setValuesForKeysWithDictionary:mutableDict];
    
    return node;
}

@end

@implementation STDAddress

+ (instancetype)shareAddress
{
    static STDAddress *address = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"STDAddressList" ofType:@"plist"];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        
         address = [STDAddress addressWithDictionary:dict];
    });
    
    return address;
}

+ (instancetype)addressWithDictionary:(NSDictionary *)dict
{
    NSArray<NSDictionary *> *childrenDicts = dict[@"children"];
    NSDictionary *nodeDict = dict[@"node"];
    
    STDAddress *address = [[STDAddress alloc] init];
    address.node = [STDAddressNode nodeWithDictionary:nodeDict];
    
    NSMutableArray<STDAddress *> *childrens = [NSMutableArray array];
    
    [childrenDicts enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [childrens addObject:[STDAddress addressWithDictionary:obj]];
    }];
    
    address.children = childrens;
    
    return address;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
