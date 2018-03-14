//
//  STDPickerScrollView.m
//  STDPickerView
//
//  Created by XuQibin on 2017/10/24.
//  Copyright © 2017年 Standards. All rights reserved.
//

#import "STDPickerContainerView.h"

static NSString * const kSTDPickerContainerCellReuseIdentifier =  @"STDPickerContainerCell";

@interface STDPickerContainerView() <UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, assign) NSInteger willSelectedRow;

@property (nonatomic, assign) NSInteger willDeselectedRow;

@property (nonatomic, assign) NSInteger currentRow;

@property (assign, nonatomic) BOOL isScrolling;

@property (assign, nonatomic) BOOL isReloadingData;

@property (assign, nonatomic) BOOL isAdjustingSelected;

@property (assign, nonatomic) CGRect rotatedRect;

@property (assign, nonatomic) BOOL isSetupDone;

@end

@implementation STDPickerContainerView

#pragma mark - life cycle
- (void)layoutSubviews
{
    if (!self.isSetupDone) {
        [self setupSubviews];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isSetupDone = YES;
            [self selectRow:self.selectedRow animated:NO];
        });
    }
    
    self.flowLayout.itemSize = CGSizeMake(self.frame.size.width, self.rowHeight);
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    if (newWindow) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive:) name:UIApplicationWillEnterForegroundNotification object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

#pragma mark - notification
- (void)applicationBecomeActive:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self adjustCurrentSelected];
    });
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if (self.isScrolling) {
        self.isScrolling = NO;

        [self selectRow:self.currentRow animated:YES];
    }
}

- (void)deviceOrientationChange:(NSNotification *)notification
{
    if (!CGSizeEqualToSize(self.rotatedRect.size, self.bounds.size)) {
        
        self.rotatedRect = self.bounds;

        [self adjustCurrentSelected];
    }
}

- (void)adjustCurrentSelected
{
    self.isAdjustingSelected = YES;
    
    [self updateCollectionViewContentInset];
    
    [self reloadDataWithLayout];
    
    if (self.numberOfRows > 0) {
        self.willDeselectedRow = -1;
        [self selectRow:self.currentRow animated:self.isScrolling];
    }
    
    self.isAdjustingSelected = NO;
}

#pragma mark - setter and getter
- (NSInteger)numberOfRows
{
    return [self.collectionView numberOfItemsInSection:0];
}

- (NSInteger)selectedRow
{
    return self.currentRow;
}

- (NSArray *)visibleItemViews
{
    NSMutableArray *views = [NSMutableArray array];
    
    [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(__kindof STDPickerContainerCell * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
        if (cell.customView) {
            [views addObject:cell.customView];
        }
    }];
    
    return views;
}

#pragma mark - setup
- (void)setupSubviews
{
    self.rotatedRect = self.bounds;
    [self setupCollectionView];
}

- (void)setupCollectionView
{
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.flowLayout.minimumLineSpacing = 0;
//    self.flowLayout.itemSize = CGSizeMake(self.frame.size.width, self.rowHeight);

    self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.flowLayout];
    
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator   = NO;
    self.collectionView.pagingEnabled                  = NO;
    self.collectionView.backgroundColor                = [UIColor clearColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    [self.collectionView registerClass:[STDPickerContainerCell class] forCellWithReuseIdentifier:kSTDPickerContainerCellReuseIdentifier];
    
    if (@available(iOS 11.0, *)) {
        [self.collectionView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
    
    CGFloat inset = (self.frame.size.height - self.rowHeight) / 2;
    self.collectionView.contentInset = UIEdgeInsetsMake(inset, 0, inset, 0);
    
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;

    [self addSubview:self.collectionView];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]|" options:0 metrics:nil views:@{@"collectionView":self.collectionView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[collectionView]|" options:0 metrics:nil views:@{@"collectionView":self.collectionView}]];
}

- (void)updateCollectionViewContentInset
{
    self.isReloadingData = YES;

//    self.flowLayout.itemSize = CGSizeMake(self.frame.size.width, self.rowHeight);
    
    CGFloat inset = (self.frame.size.height - self.rowHeight) / 2;
    self.collectionView.contentInset = UIEdgeInsetsMake(inset, 0, inset, 0);
    
    self.isReloadingData = NO;
}

#pragma mark - tools
- (void)reloadDataWithoutLayout
{
    [self.collectionView reloadData];
}

- (void)reloadDataWithLayout
{
    self.isReloadingData = YES;
    
    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];
    
    self.isReloadingData = NO;
}

- (void)reloadData
{
    [self reloadDataWithLayout];
    
    if (self.currentRow > self.numberOfRows - 1) {
        self.currentRow = self.numberOfRows - 1;
        if (self.currentRow < 0) {
            self.currentRow = 0;
        }
        
        [self.collectionView setContentOffset:CGPointMake(0, self.currentRow * self.rowHeight -self.collectionView.contentInset.top) animated:NO];
    }
    
    [self scrollViewDidScroll:self.collectionView];
}

- (void)selectRow:(NSInteger)row animated:(BOOL)animated
{
    self.currentRow = row;
    
    if (!self.isSetupDone) {
        return;
    }
    
    if (!self.isAdjustingSelected) {
        if ([self.delegate respondsToSelector:@selector(containerView:didSelectRow:)]) {
            [self.delegate containerView:self didSelectRow:self.currentRow];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CGFloat originalContentOffsetY = self.collectionView.contentOffset.y;
        CGFloat contentOffsetY = row * self.rowHeight - self.collectionView.contentInset.top;
        
        [self.collectionView setContentOffset:CGPointMake(0, contentOffsetY) animated:animated];
        if (originalContentOffsetY == contentOffsetY) {
            self.willDeselectedRow = -1;
            [self scrollViewDidScroll:self.collectionView];
        }
    });
}

- (CGSize)sizeForRow:(NSInteger)row
{
    return self.flowLayout.itemSize;
}

- (UIView *)viewForRow:(NSInteger)row
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    
    STDPickerContainerCell *cell = (STDPickerContainerCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    if (cell == nil) {
        [self.collectionView layoutIfNeeded];
        cell = (STDPickerContainerCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    }
    
    return cell.customView;
}

- (NSInteger)rowForView:(UIView *)view
{
    __block NSInteger row = -1;
    
    [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(__kindof STDPickerContainerCell * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([cell.customView isEqual:view]) {
            row = [self.collectionView indexPathForCell:cell].row;
            *stop = YES;
        }
    }];
    
    return row;
}

- (CGRect)viewRectForRow:(NSInteger)row
{
    STDPickerContainerCell *cell = (STDPickerContainerCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    
    CGRect cellRect = [_collectionView convertRect:cell.frame toView:_collectionView];
    
    return [self.collectionView convertRect:cellRect toView:self];
}

#pragma mark - UICollectionView's delegate & dataSource.

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self.dateSource numberOfRowsInContainerView:self];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    STDPickerContainerCell *cell  = [collectionView dequeueReusableCellWithReuseIdentifier:kSTDPickerContainerCellReuseIdentifier forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor clearColor];
    
    UIView *view = [self.dateSource containerView:self viewForRow:indexPath.row reusingView:cell.customView];

    if (view != nil && cell.customView == nil) {
        cell.customView = view;
        cell.customView.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:cell.customView];
        
        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[customView]|" options:0 metrics:nil views:@{@"customView":cell.customView}]];
        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[customView]|" options:0 metrics:nil views:@{@"customView":cell.customView}]];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectRow:indexPath.row animated:YES];
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    CGSize itemSize = CGSizeMake(self.frame.size.width, self.rowHeight);
//
//    return itemSize;
//}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.isScrolling = YES;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGFloat targetOffset = targetContentOffset->y + scrollView.contentInset.top;
    
    CGFloat partialRow = targetOffset / self.rowHeight;
    NSInteger roundedRow = lroundf(partialRow);
    
    if (roundedRow < 0) {
        roundedRow = 0;
    } else {
        targetContentOffset->y = (NSInteger)roundedRow * self.rowHeight - scrollView.contentInset.top;
    }
    
    self.currentRow = roundedRow;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        self.isScrolling = NO;

        if ([self.delegate respondsToSelector:@selector(containerView:didSelectRow:)]) {
            [self.delegate containerView:self didSelectRow:self.currentRow];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.isScrolling = NO;
    
    if ([self.delegate respondsToSelector:@selector(containerView:didSelectRow:)]) {
        [self.delegate containerView:self didSelectRow:self.currentRow];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.isSetupDone || self.isReloadingData) {
        return;
    }
    
    CGFloat contentOffset = scrollView.contentOffset.y + scrollView.contentInset.top;
    CGFloat partialRow = contentOffset / self.rowHeight;
    _willSelectedRow = lroundf(partialRow);
    
    if (_willSelectedRow < 0) {
        _willSelectedRow = 0;
    } else if (_willSelectedRow > [self numberOfRows] - 1) {
        _willSelectedRow = [self numberOfRows] - 1;
    }
    
    self.contentOffset = CGPointMake(scrollView.contentOffset.x, contentOffset);
    
    if ([self.delegate respondsToSelector:@selector(containerViewDidScroll:)]) {
        [self.delegate containerViewDidScroll:self];
    }
    
    if (_willSelectedRow != _willDeselectedRow) {
    
        if (_willDeselectedRow >= 0) {
            if ([self.delegate respondsToSelector:@selector(containerView:willDeselectRow:)]) {
                [self.delegate containerView:self willDeselectRow:_willDeselectedRow];
            }
        }
        
        if ([self.delegate respondsToSelector:@selector(containerView:willSelectRow:)]) {
            [self.delegate containerView:self willSelectRow:_willSelectedRow];
        }
        
        _willDeselectedRow = _willSelectedRow;
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

@implementation STDPickerContainerCell

@end
