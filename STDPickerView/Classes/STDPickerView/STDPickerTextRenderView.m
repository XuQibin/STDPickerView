//
//  STDPickerTextRenderView.m
//  STDPickerView
//
//  Created by XuQibin on 2017/10/26.
//  Copyright © 2017年 Standards. All rights reserved.
//

#import "STDPickerTextRenderView.h"

@interface STDPickerTextRenderView()

@property (nonatomic, strong, nonnull) NSDictionary<NSString *, id> *unselectedTextAttributes;
@property (nonatomic, strong, nonnull) NSDictionary<NSString *, id> *selectedTextAttributes;

@property (assign, nonatomic) NSLineBreakMode lineBreakMode;

@end

@implementation STDPickerTextRenderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _font = [UIFont systemFontOfSize:14.0f];

        _textColor = [UIColor darkGrayColor];
        _selectedTextColor = [UIColor blackColor];
        
        self.enableLineWrap = YES;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGFloat unselectedTextRectHeight = [self.text boundingRectWithSize:rect.size options:NSStringDrawingUsesLineFragmentOrigin attributes:self.unselectedTextAttributes context:nil].size.height;
    
    CGRect unselectedTextDrawingRect = CGRectMake(rect.origin.x,
                                                  rect.origin.y + (rect.size.height - unselectedTextRectHeight) / 2.0f,
                                                  rect.size.width,
                                                  unselectedTextRectHeight);
    
    [self.text drawInRect:unselectedTextDrawingRect withAttributes:self.unselectedTextAttributes];
    
    CGContextRestoreGState(context);
    
    if (!CGRectIsEmpty(self.selectedTextDrawingRect)) {
        
        CGFloat selectedTextRectHeight = [self.text boundingRectWithSize:rect.size options:NSStringDrawingUsesLineFragmentOrigin attributes:self.selectedTextAttributes context:nil].size.height;

        CGRect selectedTextDrawingRect = CGRectMake(rect.origin.x,
                                                    rect.origin.y + (rect.size.height - selectedTextRectHeight) / 2.0f,
                                                    rect.size.width,
                                                    selectedTextRectHeight);
        CGContextClipToRect(context, self.selectedTextDrawingRect);
        
        [self.text drawInRect:selectedTextDrawingRect withAttributes:self.selectedTextAttributes];
    }
}

#pragma mark - setup

- (void)setupSelectedAttributes {
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.lineBreakMode = self.lineBreakMode;
    
    NSDictionary *selectedAttributes = @{ NSFontAttributeName: self.font,
                                          NSForegroundColorAttributeName: self.selectedTextColor,
                                          NSParagraphStyleAttributeName: paragraphStyle };
    
    self.selectedTextAttributes = selectedAttributes;
}

- (void)setupUnselectedAttributes {
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.lineBreakMode = self.lineBreakMode;

    NSDictionary *unselectedAttributes = @{ NSFontAttributeName: self.font,
                                            NSForegroundColorAttributeName: self.textColor,
                                            NSParagraphStyleAttributeName: paragraphStyle };
    
    self.unselectedTextAttributes = unselectedAttributes;
}

#pragma mark - setter and getter

- (void)setEnableLineWrap:(BOOL)enableLineWrap
{
    _enableLineWrap = enableLineWrap;
    
    self.lineBreakMode = enableLineWrap ? NSLineBreakByWordWrapping : NSLineBreakByTruncatingTail;
    
    [self setupSelectedAttributes];
    [self setupUnselectedAttributes];
}

- (void)setSelectedTextDrawingRect:(CGRect)selectedTextDrawingRect {
    _selectedTextDrawingRect = selectedTextDrawingRect;
    
    [self setNeedsDisplay];
}

- (void)setText:(NSString *)text
{
    _text = text;
    
    [self setNeedsDisplay];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    
    [self setupUnselectedAttributes];
}

- (void)setSelectedTextColor:(UIColor *)selectedTextColor {
    _selectedTextColor = selectedTextColor;
    
    [self setupSelectedAttributes];
}

//- (void)setSelectedFont:(UIFont *)selectedFont {
//    _selectedFont = selectedFont;
//
//    [self setupSelectedAttributes];
//}

- (void)setFont:(UIFont *)font {
    _font = font;
    
    [self setupUnselectedAttributes];
    [self setupSelectedAttributes];
}

@end
