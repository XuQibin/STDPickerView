//
//  STDPickerView.m
//  STDPickerView
//
//  Created by XuQibin on 2017/6/19.
//  Copyright © 2017年 Standards. All rights reserved.
//

#import "STDPickerView.h"
#import "STDPickerContainerView.h"
#import "STDPickerTextRenderView.h"

static CGFloat kSTDPickerViewDefaultRowHeight = 44;
static CGFloat kSTDPickerViewDefaultSpacingOfComponents = 10;

@interface STDPickerView() <STDPickerContainerViewDelegate,STDPickerContainerViewDateSource>

@property (strong, nonatomic) UIView *selectionIndicatorView;

@property (nonatomic, strong) NSMutableArray<STDPickerContainerView *> *containers;

@property (strong, nonatomic) NSMutableArray *selectedRowsMap;

@property (assign, nonatomic) BOOL isSetupDone;

@property (assign, nonatomic) BOOL isItemTypeText;

@end

@implementation STDPickerView

#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self setupBaseConfig];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setupBaseConfig];
    }
    
    return self;
}

- (void)layoutSubviews
{
    if (!self.isSetupDone) {
        [self setupContainerView];

        for (NSUInteger i = 0; i < self.selectedRowsMap.count; i++) {
            [self selectRow:[self.selectedRowsMap[i] unsignedIntegerValue] inComponent:i animated:NO];
        }
        
        self.isSetupDone = YES;
    }
}

#pragma mark - setter and getter
- (NSMutableArray *)selectedRowsMap
{
    if (!_selectedRowsMap) {
        NSUInteger components = [self.dataSource numberOfComponentsInPickerView:self];

        _selectedRowsMap = [NSMutableArray arrayWithCapacity:components];
        
        for (NSUInteger i = 0; i < components; i++) {
            [_selectedRowsMap addObject:@(0)];
        }
    }
    
    return _selectedRowsMap;
}

- (NSMutableArray<STDPickerContainerView *> *)containers
{
    if (!_containers) {
        _containers = [NSMutableArray array];
    }
    
    return _containers;
}

- (void)setForceItemTypeText:(BOOL)forceItemTypeText
{
    _forceItemTypeText = forceItemTypeText;

    if (forceItemTypeText) {
        NSAssert(self.dataSource, @"You need to config 'dataSource' first");
    }
    
    if (!self.isItemTypeText) {
        self.isItemTypeText = forceItemTypeText;
    }
}

- (void)setDataSource:(id<STDPickerViewDataSource>)dataSource
{
    _dataSource = dataSource;
    
    if ([dataSource respondsToSelector:@selector(pickerView:viewForRow:forComponent:reusingView:)]) {
        self.isItemTypeText = NO;
    } else if ([dataSource respondsToSelector:@selector(pickerView:titleForRow:forComponent:)]) {
        self.isItemTypeText = YES;
    } else {
        NSAssert(0, @"You need to implement 'pickerView:viewForRow:forComponent:reusingView:' or 'pickerView:titleForRow:forComponent:'");
    }
}

- (void)setSelectionIndicatorStyle:(STDPickerViewSelectionIndicatorStyle)selectionIndicatorStyle
{
    _selectionIndicatorStyle = selectionIndicatorStyle;
    
    if (self.selectionIndicatorView) {
        [self.selectionIndicatorView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview) withObject:nil];
        
        if (selectionIndicatorStyle == STDPickerViewSelectionIndicatorStyleDefault) {
            
            [self setupSelectionIndicatorStyleDefault];
            
        } else if (selectionIndicatorStyle == STDPickerViewSelectionIndicatorStyleDivision) {
            
            [self setupSelectionIndicatorStyleDivision];
            
        } else if (selectionIndicatorStyle == STDPickerViewSelectionIndicatorStyleCustom) {
            
            [self setupSelectionIndicatorStyleCustom];
            
        } else {
            self.selectionIndicatorView.hidden = YES;
        }
    }
}

#pragma mark - setup

- (void)setupBaseConfig
{
    _selectionIndicatorStyle = STDPickerViewSelectionIndicatorStyleDefault;
    
    _font = [UIFont systemFontOfSize:14];
    _textColor = [UIColor lightGrayColor];
    _selectedTextColor = [UIColor blackColor];
    
    _edgeInsets = UIEdgeInsetsZero;
    _spacingOfComponents = kSTDPickerViewDefaultSpacingOfComponents;
}

- (void)setupContainerView
{
    if (!self.dataSource) {
        return;
    }
    
    NSUInteger components = [self.dataSource numberOfComponentsInPickerView:self];
    
    UIEdgeInsets edgeInsets = self.edgeInsets;
    CGFloat spaceOfComponents = components > 1 ? self.spacingOfComponents : 0;
 
    CGFloat totalRatio = 0;
    NSMutableArray<NSNumber *> *widthRatios = [NSMutableArray array];
    if ([self.delegate respondsToSelector:@selector(pickerView:widthRatioForComponent:)]) {
        for (NSUInteger i = 0; i < components; i++) {
            CGFloat ratio = [self.delegate pickerView:self widthRatioForComponent:i];
            totalRatio += ratio;
            [widthRatios addObject:@(ratio)];
        }
        
        if (totalRatio != 1) {
            [widthRatios removeAllObjects];
            totalRatio = 0;
            NSLog(@"warning: The sum of 'pickerView:widthRatioForComponent:' must be equal to 1");
        }
    }
    if (totalRatio == 0) {
        for (NSUInteger i = 0; i < components; i++) {
            [widthRatios addObject:@(1.0f / components)];
        }
    }

    NSMutableString *visualFormat = [NSMutableString string];
    NSMutableDictionary *viewsMap = [NSMutableDictionary dictionary];
    for (NSUInteger i = 0; i < components; i++) {
        
        STDPickerContainerView *container = [[STDPickerContainerView alloc] init];
        [self.containers addObject:container];
        container.rowHeight = [self rowHeightForComponent:i];
        container.delegate = self;
        container.dateSource = self;
        container.layer.masksToBounds = YES;
        
        container.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:container];
        
        //add width constraint
        [self addConstraint:[NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:widthRatios[i].floatValue constant:-(spaceOfComponents * (components - 1) + edgeInsets.left + edgeInsets.right) / components]];
        
        //add vertical constraint
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%f-[container]-%f-|", edgeInsets.top, edgeInsets.bottom] options:0 metrics:nil views:@{@"container":container}]];
        
        //record horizontal visual format
        if (i < components - 1) {
            [visualFormat appendFormat:@"[container%zd]-%f-", i, spaceOfComponents];
        } else {
            [visualFormat appendFormat:@"[container%zd]", i];
        }
        [viewsMap setObject:container forKey:[NSString stringWithFormat:@"container%zd",i]];
    }
    
    NSString *hVisualFormat = [NSString stringWithFormat:@"H:|-%f-%@-%f-|", edgeInsets.left, visualFormat, edgeInsets.right];
    
    //add horizontal constraint
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:hVisualFormat options:0 metrics:nil views:viewsMap]];
    
    [self setupSelectionIndicatorView];
    [self setupVerticalDivisionLine];
    self.selectionIndicatorStyle = self.selectionIndicatorStyle;
}

- (void)setupVerticalDivisionLine
{
    if (!self.showVerticalDivisionLine) {
        return;
    }
    
    NSUInteger components = [self.dataSource numberOfComponentsInPickerView:self];

    UIEdgeInsets edgeInsets = self.edgeInsets;
    CGFloat space = (components > 1 ? self.spacingOfComponents : 0) / 2;
    
    for (NSUInteger i = 0; i < components - 1; i++) {
        STDPickerContainerView *containerView = self.containers[i];
        
        UIView *divisionLine = [[UIView alloc] init];
        
        divisionLine.backgroundColor = self.selectionIndicatorLineColor ? : [UIColor groupTableViewBackgroundColor];

        divisionLine.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:divisionLine];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[containerView]-space-[divisionLine(==1)]" options:0 metrics:@{@"space":@(space)} views:@{@"containerView":containerView, @"divisionLine":divisionLine}]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topSpace-[divisionLine]-bottomSpace-|" options:0 metrics:@{@"topSpace":@(edgeInsets.top),@"bottomSpace":@(edgeInsets.bottom)} views:@{@"divisionLine":divisionLine}]];
    }
}

- (void)setupSelectionIndicatorView
{
    CGFloat indicatorHeight = [self selectionIndicatorHeight];
    
    UIView *selectionIndicatorView = [[UIView alloc] init];
    
    selectionIndicatorView.backgroundColor = [UIColor clearColor];
    selectionIndicatorView.userInteractionEnabled = NO;
    
    selectionIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;

    [self addSubview:selectionIndicatorView];
    self.selectionIndicatorView = selectionIndicatorView;
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[indicatorView]|" options:0 metrics:nil views:@{@"indicatorView":selectionIndicatorView}]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[indicatorView(==indicatorHeight)]" options:0 metrics:@{@"indicatorHeight":@(indicatorHeight)} views:@{@"indicatorView":selectionIndicatorView}]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:selectionIndicatorView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
}

- (void)setupSelectionIndicatorStyleDefault
{
    for (NSUInteger i = 0; i < 2; i++) {
        UIView *line = [[UIView alloc] init];
        
        line.backgroundColor = self.selectionIndicatorLineColor ? : [UIColor groupTableViewBackgroundColor];
        
        line.translatesAutoresizingMaskIntoConstraints = NO;

        [self.selectionIndicatorView addSubview:line];
        
        [self.selectionIndicatorView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[line]|" options:0 metrics:nil views:@{@"line":line}]];
        
        NSString *vVisualFormat = i == 0 ? @"V:|[line(==1)]" : @"V:[line(==1)]-1-|";
        [self.selectionIndicatorView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vVisualFormat options:0 metrics:nil views:@{@"line":line}]];
    }
}

- (void)setupSelectionIndicatorStyleDivision
{
    CGFloat indicatorHeight = [self selectionIndicatorHeight];
    
    for (NSUInteger i = 0; i < 2; i++) {
        
        for (STDPickerContainerView *containerView in self.containers) {
            
            CGFloat rowHeight = containerView.rowHeight;
            CGFloat space = (indicatorHeight - rowHeight) / 2;
            
            UIView *line = [[UIView alloc] init];
            
            line.backgroundColor = self.selectionIndicatorLineColor ? : [UIColor groupTableViewBackgroundColor];
            
            line.translatesAutoresizingMaskIntoConstraints = NO;
            
            [self.selectionIndicatorView addSubview:line];
            
            [self addConstraint:[NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];

            [self addConstraint:[NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];

            NSString *vVisualFormat = i == 0 ? @"V:|-space-[line(==1)]" : @"V:[line(==1)]-space-|";
            [self.selectionIndicatorView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vVisualFormat options:0 metrics:@{@"space":@(i == 0 ? space : space + 1)} views:@{@"line":line}]];
        }
    }
}

- (void)setupSelectionIndicatorStyleCustom
{
    if ([self.delegate respondsToSelector:@selector(selectionIndicatorViewForPickerView:)]) {
        UIView *view = [self.delegate selectionIndicatorViewForPickerView:self];
        
        if (view) {
            view.translatesAutoresizingMaskIntoConstraints = NO;

            [self.selectionIndicatorView addSubview:view];
            
            [self.selectionIndicatorView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[indicatorView]|" options:0 metrics:nil views:@{@"indicatorView":view}]];
            [self.selectionIndicatorView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[indicatorView]|" options:0 metrics:nil views:@{@"indicatorView":view}]];
        }
    }
}

#pragma mark container dataSource

- (NSInteger)numberOfRowsInContainerView:(STDPickerContainerView *)containerView
{
    NSUInteger component = [self.containers indexOfObject:containerView];
    NSUInteger numberOfRows = [self.dataSource pickerView:self numberOfRowsInComponent:component];
    
    return numberOfRows;
}

- (UIView *)containerView:(STDPickerContainerView *)containerView viewForRow:(NSInteger)row reusingView:(UIView *)view
{
    NSUInteger component = [self.containers indexOfObject:containerView];
    
    if (!self.isItemTypeText) {
        
        view = [self.dataSource pickerView:self viewForRow:row forComponent:component reusingView:view];
        
        CGRect frame = view.frame;
        frame.size = CGSizeMake(containerView.frame.size.width, [self rowHeightForComponent:component]);
        view.frame = frame;
    } else {
        STDPickerTextRenderView *textView = (STDPickerTextRenderView *)view;
        
        if (!textView) {
            textView = [[STDPickerTextRenderView alloc] initWithFrame:CGRectMake(0, 0, containerView.frame.size.width, [self rowHeightForComponent:component])];
            
            textView.backgroundColor = [UIColor clearColor];
            textView.textColor = self.textColor;
            textView.font = self.font;
            textView.selectedTextColor = self.selectedTextColor;
            
            view = textView;
        }
        
        NSString *title = [self.dataSource pickerView:self titleForRow:row forComponent:component];
        
        textView.text = title;
    }
    
    return view;
}

#pragma mark container delegate

- (void)containerViewDidScroll:(STDPickerContainerView *)containerView
{
    NSUInteger component = [self.containers indexOfObject:containerView];
    
    if ([self.delegate respondsToSelector:@selector(pickerView:didScroll:inComponent:)]) {
        [self.delegate pickerView:self didScroll:containerView.contentOffset inComponent:component];
    }
    
    if (self.isItemTypeText) {
        CGFloat contentOffset = containerView.contentOffset.y;
        CGFloat partialRow = contentOffset / containerView.rowHeight;
        
        NSInteger ceilRow = ceilf(partialRow);//向上取整 eg.ceilf(3.14) = 4
        NSInteger floorRow = floorf(partialRow);//向下取整 eg.floorf(3.14) = 3
        
        [containerView.visibleItemViews enumerateObjectsUsingBlock:^(STDPickerTextRenderView  *_Nonnull textView, NSUInteger idx, BOOL * _Nonnull stop) {
            textView.selectedTextDrawingRect = CGRectZero;
            
        }];
        
        if (floorRow < 0) {
            [self renderTextViewInRow:0 forContainerView:containerView];
        } else if (ceilRow > [containerView numberOfRows] - 1) {
            [self renderTextViewInRow:[containerView numberOfRows] - 1 forContainerView:containerView];
        } else {
            [self renderTextViewInRow:ceilRow forContainerView:containerView];
            [self renderTextViewInRow:floorRow forContainerView:containerView];
        }
    }
}

- (void)containerView:(STDPickerContainerView *)containerView willSelectRow:(NSUInteger)row
{
    NSUInteger component = [self.containers indexOfObject:containerView];
    
    if ([self.delegate respondsToSelector:@selector(pickerView:willSelectRow:inComponent:)]) {
        [self.delegate pickerView:self willSelectRow:row inComponent:component];
    }
}

- (void)containerView:(STDPickerContainerView *)containerView didSelectRow:(NSUInteger)row
{
    NSUInteger component = [self.containers indexOfObject:containerView];
    
    if ([self.delegate respondsToSelector:@selector(pickerView:didSelectRow:inComponent:)]) {
        [self.delegate pickerView:self didSelectRow:row inComponent:component];
    }
}

- (void)containerView:(STDPickerContainerView *)containerView willDeselectRow:(NSUInteger)row
{
    NSUInteger component = [self.containers indexOfObject:containerView];
    
    if ([self.delegate respondsToSelector:@selector(pickerView:willDeselectRow:inComponent:)]) {
        [self.delegate pickerView:self willDeselectRow:row inComponent:component];
    }
}

#pragma mark - tools
- (void)renderTextViewInRow:(NSInteger)row forContainerView:(STDPickerContainerView *)containerView
{
    STDPickerTextRenderView *textView = (STDPickerTextRenderView *)[containerView viewForRow:row];
    
    CGRect textViewRect = [textView.superview convertRect:textView.frame toView:self];
    
    CGRect intersectionRect = CGRectIntersection(textViewRect, self.selectionIndicatorView.frame);
    
    CGFloat offsetY = 0;
    if (textViewRect.origin.y < self.selectionIndicatorView.frame.origin.y) {
        offsetY = self.selectionIndicatorView.frame.origin.y - textViewRect.origin.y;
    }
    
    textView.selectedTextDrawingRect = CGRectMake(0, offsetY, intersectionRect.size.width, intersectionRect.size.height);
}

- (CGFloat)selectionIndicatorHeight
{
    CGFloat indicatorHeight = 0;
    
    if ([self.delegate respondsToSelector:@selector(pickerView:rowHeightForComponent:)]) {
        
        for (NSUInteger i = 0; i < self.containers.count; i++) {
            CGFloat rowHeight = [self.delegate pickerView:self rowHeightForComponent:i];
            
            if (rowHeight > indicatorHeight) {
                indicatorHeight = rowHeight;
            }
        }
    } else {
        indicatorHeight = kSTDPickerViewDefaultRowHeight;
    }
    
    return indicatorHeight;
}

- (CGFloat)rowHeightForComponent:(NSUInteger)component
{
    if ([self.delegate respondsToSelector:@selector(pickerView:rowHeightForComponent:)]) {
        CGFloat rowHeight = [self.delegate pickerView:self rowHeightForComponent:component];
        
        return rowHeight;
    }
    
    return kSTDPickerViewDefaultRowHeight;
}

- (NSInteger)numberOfRowsInComponent:(NSInteger)component {

    if (self.containers.count <= component) {
        return -1;
    }
    
    STDPickerContainerView *container = [self.containers objectAtIndex:component];

    return [container numberOfRows];
}

- (CGSize)rowSizeForComponent:(NSInteger)component {

    if (self.containers.count <= component) {
        return CGSizeZero;
    }
    STDPickerContainerView *container = [self.containers objectAtIndex:component];
    
    return [container sizeForRow:0];
}

// returns the view provided by the delegate via pickerView:viewForRow:forComponent:reusingView:
// or nil if the row/component is not visible or the delegate does not implement
// pickerView:viewForRow:forComponent:reusingView:
- (nullable UIView *)viewForRow:(NSInteger)row forComponent:(NSInteger)component {

    if (self.containers.count <= component) {
        return nil;
    }
    
    STDPickerContainerView *container = [self.containers objectAtIndex:component];
    
    return [container viewForRow:row];
}

// Reloading whole view or single component
- (void)reloadAllComponents {
    
    for (STDPickerContainerView *container in self.containers) {
        [container reloadData];
    }
}

- (void)reloadComponent:(NSInteger)component {
    
    if (self.containers.count <= component) {
        return;
    }
    
    STDPickerContainerView *container = [self.containers objectAtIndex:component];
    
    [container reloadData];
}

// selection. in this case, it means showing the appropriate row in the middle
- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated {
    
    NSAssert(self.dataSource, @"please set dataSource before calling 'selectRow:inComponent:animated:'");
    
    if (self.selectedRowsMap.count > component) {
        [self.selectedRowsMap replaceObjectAtIndex:component withObject:@(row)];
    }
    
    if (self.containers.count <= component) {
        return;
    }
    
    STDPickerContainerView *container = [self.containers objectAtIndex:component];
    
    [container selectRow:row animated:animated];
}

- (NSInteger)selectedRowInComponent:(NSInteger)component {
    if (self.containers.count <= component) {
        return -1;
    }
    
    STDPickerContainerView *container = [self.containers objectAtIndex:component];

    return container.selectedRow;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
