# STDPickerView

[![Version](https://img.shields.io/cocoapods/v/STDPickerView.svg?style=flat)](http://cocoapods.org/pods/STDPickerView)
[![License](https://img.shields.io/cocoapods/l/STDPickerView.svg?style=flat)](http://cocoapods.org/pods/STDPickerView)
[![Platform](https://img.shields.io/cocoapods/p/STDPickerView.svg?style=flat)](http://cocoapods.org/pods/STDPickerView)

# STDPickerView 是什么
STDPickerView 是基于 UICollectionView 封装的选择控件，兼容UIPickerView大部分接口，并增加了多个定制化接口，可实现更多的效果！

# STDPickerView 怎么使用
* 初始化

``` objc
STDPickerView *pickerView = [[STDPickerView alloc] init];
    
pickerView.dataSource = self;
pickerView.delegate = self;

／*
	STDPickerViewSelectionIndicatorStyleNone：无选中指示器
	STDPickerViewSelectionIndicatorStyleDefault：默认选中指示器
	STDPickerViewSelectionIndicatorStyleDivision: 分段选中指示器
	STDPickerViewSelectionIndicatorStyleCustom：自定义选中指示器，需实现 selectionIndicatorViewInPickerView: 代理方法
*／
pickerView.selectionIndicatorStyle = STDPickerViewSelectionIndicatorStyleDefault;

/* 
	默认情况下，如果同时实现了titleForRow以及viewForRow数据源方法，
	则会优先使用viewForRow方法返回自定义view，
	此时可设置 forceItemTypeText = YES 来指定使用titleForRow方法
*/
pickerView.forceItemTypeText = YES;

//是否显示垂直分割线
pickerView.showVerticalDivisionLine = YES;
    
//设置pickerView四周的间距
pickerView.edgeInsets = UIEdgeInsetsMake(0, 20, 0, 20);

//设置component之间的间距
pickerView.spacingOfComponents = 30;

//仅在文本模式下有效
pickerView.textColor = kLightTextColor;
pickerView.selectedTextColor = kGlobalColor;
pickerView.font = [UIFont systemFontOfSize:16];

...

[self.view addSubview:pickerView];

```


* 通用数据源及代理方法

``` objc

#pragma mark - STDPickerViewDataSource

//返回component数目
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

//返回row数目
- (NSInteger)pickerView:(STDPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.items.count;
}


#pragma mark - STDPickerViewDelegate

//返回条目高度
- (CGFloat)pickerView:(STDPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 60;
}

//选中了某个条目
- (void)pickerView:(STDPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	NSLog(@"pickerView - didSelectRow %zd inComponent %zd", row, component);
}

//若selectionIndicatorStyle = STDPickerViewSelectionIndicatorStyleCustom，则需实现以下方法
- (UIView *)selectionIndicatorViewInPickerView:(STDPickerView *)pickerView
{
    UIView *view = [[UIView alloc] init];
    
    view.backgroundColor = kGlobalColorWithAlpha(0.3);
    
    view.layer.cornerRadius = 5;
    view.layer.masksToBounds = YES;
    
    return view;
}

...


```

* 默认选中样式

``` objc
#pragma mark - STDPickerViewDataSource

// 返回item的标题
（注：若同时实现了 pickerView: viewForRow:forComponent:reusingView: 优先采用后者，此时可通过设置 forceItemTypeText = YES 来强制使用本方法）
- (NSString *)pickerView:(STDPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.items[row];
}

```

* 自定义选中样式

``` objc
#pragma mark - STDPickerViewDataSource

// 返回item的自定义view，优先级较高
（注：若同时实现了 pickerView: titleForRow:forComponent: 且 forceItemTypeText = YES 则本方法无效）
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

//可在此方法及willDeselectRow中实现自定义的切换效果
- (void)pickerView:(STDPickerView *)pickerView willSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    UILabel *label = (UILabel *)[pickerView viewForRow:row forComponent:component];
    
    [UIView animateWithDuration:0.25 animations:^{
        label.transform = CGAffineTransformMakeScale(1.5, 1.5);
    }];
    
    label.textColor = kGlobalColor;    
}

- (void)pickerView:(STDPickerView *)pickerView willDeselectRow:(NSInteger)row inComponent:(NSInteger)component
{
    UILabel *label = (UILabel *)[pickerView viewForRow:row forComponent:component];
    
    [UIView animateWithDuration:0.25 animations:^{
        label.transform = CGAffineTransformIdentity;
    }];
    
    label.textColor = kLightTextColor;
}


```

# STDPickerView 效果图
![](Resource/01.gif)
