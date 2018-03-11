//
//  STDPickerScrollView.h
//  STDPickerView
//
//  Created by XuQibin on 2017/10/24.
//  Copyright © 2017年 Standards. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STDPickerContainerView;

@protocol STDPickerContainerViewDateSource <NSObject>

- (NSInteger)numberOfRowsInContainerView:(STDPickerContainerView *)containerView;

- (UIView *)containerView:(STDPickerContainerView *)containerView viewForRow:(NSInteger)row reusingView:(UIView *)view;

@end

@protocol STDPickerContainerViewDelegate <NSObject>

@optional
- (void)containerView:(STDPickerContainerView *)containerView willSelectRow:(NSUInteger)row;

- (void)containerView:(STDPickerContainerView *)containerView willDeselectRow:(NSUInteger)row;

- (void)containerView:(STDPickerContainerView *)containerView didSelectRow:(NSUInteger)row;

- (void)containerViewDidScroll:(STDPickerContainerView *)containerView;

@end

@interface STDPickerContainerView : UIView

@property (weak, nonatomic) id<STDPickerContainerViewDelegate> delegate;

@property (weak, nonatomic) id<STDPickerContainerViewDateSource> dateSource;

@property (assign, nonatomic) NSUInteger rowHeight;

@property (assign, nonatomic) CGPoint contentOffset;  // default CGPointZero

// info that was fetched and cached from the data source and delegate
@property(assign, readonly, nonatomic) NSInteger numberOfRows;
@property(assign, readonly, nonatomic) NSInteger selectedRow;

@property(strong, readonly, nonatomic) NSArray *visibleItemViews;

- (CGSize)sizeForRow:(NSInteger)row;
- (UIView *)viewForRow:(NSInteger)row;
- (NSInteger)rowForView:(UIView *)view;
- (CGRect)viewRectForRow:(NSInteger)row;

- (void)reloadData;
- (void)reloadDataWithoutLayout;

- (void)selectRow:(NSInteger)row animated:(BOOL)animated;  // scrolls the specified row to center.

@end


@interface STDPickerContainerCell : UICollectionViewCell

@property (strong, nonatomic) UIView *customView;

@end

