//
//  STDPickerTextRenderView.m
//  STDPickerView
//
//  Created by XuQibin on 2017/10/26.
//  Copyright © 2017年 Standards. All rights reserved.
//

#import "STDPickerTextRenderView.h"
#import <CoreText/CoreText.h>

@interface STDPickerTextRenderView()

@property (nonatomic, strong, nonnull) NSDictionary<NSString *, id> *unselectedCoreTextAttributes;
@property (nonatomic, strong, nonnull) NSDictionary<NSString *, id> *selectedCoreTextAttributes;

@property (assign, nonatomic) NSLineBreakMode lineBreakMode;

@end

@implementation STDPickerTextRenderView

#pragma mark - initialization
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setupBaseConfig];
    }
    
    return self;
}

#pragma mark - draw tools
CTLineBreakMode CTLineBreakModeFromUILineBreakMode(NSLineBreakMode alignment) {
    switch (alignment) {
        case NSLineBreakByWordWrapping: return kCTLineBreakByWordWrapping;
        case NSLineBreakByTruncatingTail: return kCTLineBreakByTruncatingTail;
        default: return kCTLineBreakByTruncatingTail;
    }
}

CTTextAlignment CTTextAlignmentFromUITextAlignment(NSTextAlignment alignment) {
    switch (alignment) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
        case NSTextAlignmentLeft: return kCTLeftTextAlignment;
        case NSTextAlignmentCenter: return kCTCenterTextAlignment;
        case NSTextAlignmentRight: return kCTRightTextAlignment;
        default: return kCTNaturalTextAlignment;
#pragma clang diagnostic pop
    }
}

- (CGFloat)heightWithString:(NSAttributedString *)string rect:(CGRect)rect
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, rect.size.width, 1000));
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)string);
    CTFrameRef textFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    
    CGPathRelease(path);
    CFRelease(framesetter);
    
    CFArrayRef lines = CTFrameGetLines(textFrame);
    NSInteger numberOfLines = CFArrayGetCount(lines);
    CGPoint lineOrigins[numberOfLines];
    
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0, numberOfLines), lineOrigins);
    
    CGFloat textHeight = 0;
    for (NSInteger lineIndex = numberOfLines - 1; lineIndex >= 0; lineIndex--) {
        CGPoint lineOrigin = lineOrigins[lineIndex];
        
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
        
        CGFloat ascent, descent, leading;
        CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        
        textHeight = 1000 - lineOrigin.y + descent;
        
        if (textHeight <= rect.size.height) {
            break;
        }
    }
    
    CFRelease(textFrame);
    
    return textHeight;
}

- (void)drawAttributedString:(NSAttributedString *)attributedString
              textRange:(CFRange)textRange
                 inRect:(CGRect)rect
                context:(CGContextRef)c
{
    CGPathRef path = CGPathCreateWithRect(rect, nil);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedString);

    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, textRange, path, NULL);
    
    CFArrayRef lines = CTFrameGetLines(frame);
    NSInteger numberOfLines = CFArrayGetCount(lines);
    BOOL truncateLastLine = YES; //tailMode
    
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), lineOrigins);
    for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
        CGPoint lineOrigin = lineOrigins[lineIndex];
        
        CGContextSetTextPosition(c, lineOrigin.x, lineOrigin.y);
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
        
        CGFloat descent = 0.0f;
        CGFloat ascent = 0.0f;
        CGFloat lineLeading;
        CTLineGetTypographicBounds((CTLineRef)line, &ascent, &descent, &lineLeading);
        
        // Adjust pen offset for flush depending on text alignment
        CGFloat flushFactor = 0.5; //center
        CGFloat penOffset;
        CGFloat y;
        if (lineIndex == numberOfLines - 1 && truncateLastLine) {
            // Check if the range of text in the last line reaches the end of the full attributed string
            CFRange lastLineRange = CTLineGetStringRange(line);
            
            if (!(lastLineRange.length == 0 && lastLineRange.location == 0) && lastLineRange.location + lastLineRange.length < textRange.location + textRange.length) {
                // Get correct truncationType and attribute position
                CTLineTruncationType truncationType = kCTLineTruncationEnd;
                CFIndex truncationAttributePosition = lastLineRange.location;
                
                NSString *truncationTokenString = @"\u2026";
                
                NSDictionary *truncationTokenStringAttributes = [attributedString attributesAtIndex:(NSUInteger)truncationAttributePosition effectiveRange:NULL];
                
                NSAttributedString *attributedTokenString = [[NSAttributedString alloc] initWithString:truncationTokenString attributes:truncationTokenStringAttributes];
                CTLineRef truncationToken = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attributedTokenString);
                
                // Append truncationToken to the string
                // because if string isn't too long, CT wont add the truncationToken on it's own
                // There is no change of a double truncationToken because CT only add the token if it removes characters (and the one we add will go first)
                NSMutableAttributedString *truncationString = [[attributedString attributedSubstringFromRange:NSMakeRange((NSUInteger)lastLineRange.location, (NSUInteger)lastLineRange.length)] mutableCopy];
                if (lastLineRange.length > 0) {
                    // Remove any newline at the end (we don't want newline space between the text and the truncation token). There can only be one, because the second would be on the next line.
                    unichar lastCharacter = [[truncationString string] characterAtIndex:(NSUInteger)(lastLineRange.length - 1)];
                    if ([[NSCharacterSet newlineCharacterSet] characterIsMember:lastCharacter]) {
                        [truncationString deleteCharactersInRange:NSMakeRange((NSUInteger)(lastLineRange.length - 1), 1)];
                    }
                }
                [truncationString appendAttributedString:attributedTokenString];
                CTLineRef truncationLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)truncationString);
                
                // Truncate the line in case it is too long.
                CTLineRef truncatedLine = CTLineCreateTruncatedLine(truncationLine, rect.size.width, truncationType, truncationToken);
                if (!truncatedLine) {
                    // If the line is not as wide as the truncationToken, truncatedLine is NULL
                    truncatedLine = CFRetain(truncationToken);
                }
                
                penOffset = (CGFloat)CTLineGetPenOffsetForFlush(truncatedLine, flushFactor, rect.size.width);
                y = lineOrigin.y - descent - self.font.descender - 1;
                CGContextSetTextPosition(c, penOffset, y);
                
                CTLineDraw(truncatedLine, c);
                
                CFRelease(truncatedLine);
                CFRelease(truncationLine);
                CFRelease(truncationToken);
            } else {
                penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, flushFactor, rect.size.width);
                y = lineOrigin.y - descent - self.font.descender - 1;
                CGContextSetTextPosition(c, penOffset, y);
                CTLineDraw(line, c);
            }
        } else {
            penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, flushFactor, rect.size.width);
            y = lineOrigin.y - descent - self.font.descender - 1;
            CGContextSetTextPosition(c, penOffset, y);
            CTLineDraw(line, c);
        }
    }
    
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
}

- (void)drawText:(NSString *)text rect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    //Create attributed string, with applied syntax highlighting
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text attributes:_unselectedCoreTextAttributes];
    
    CGFloat textHeight = [self heightWithString:attributedString rect:rect];
    CGRect textDrawingRect = CGRectMake(rect.origin.x,
                                        rect.origin.y + (rect.size.height - textHeight) / 2.0f,
                                        rect.size.width,
                                        rect.size.height - (rect.size.height - textHeight) / 2.0f);
    
    [self drawAttributedString:attributedString textRange:CFRangeMake(0, text.length) inRect:textDrawingRect context:context];
    
    if (!CGRectIsEmpty(_selectedTextDrawingRect)) {
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text attributes:_selectedCoreTextAttributes];

        CGAffineTransform transform = CGAffineTransformMakeTranslation(0, rect.size.height);
        transform = CGAffineTransformScale(transform, 1.f, -1.f);
        CGRect selectedRect = CGRectApplyAffineTransform(_selectedTextDrawingRect, transform);

        CGContextClipToRect(context, selectedRect);

        [self drawAttributedString:attributedString textRange:CFRangeMake(0, text.length) inRect:textDrawingRect context:context];
    }
}

#pragma mark - drawRect

- (void)drawRect:(CGRect)rect {
    
    [self drawText:self.text rect:rect];
}

#pragma mark - setup
- (void)setupBaseConfig
{
    _font = [UIFont systemFontOfSize:14.0f];
    
    _textColor = [UIColor darkGrayColor];
    _selectedTextColor = [UIColor blackColor];
    _selectedTextDrawingRect = CGRectZero;
    _enableLineWrap = YES;
    
    [self setupCoreTextAttributes];
}

- (void)setupCoreTextAttributes
{
    _lineBreakMode = _enableLineWrap ? NSLineBreakByWordWrapping : NSLineBreakByTruncatingTail;

    //Set line height, font, color and break mode
    CGFloat minimumLineHeight = self.font.pointSize, maximumLineHeight = minimumLineHeight, linespace = 8;
    CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)self.font.fontName, self.font.pointSize, NULL);
    CTLineBreakMode lineBreakMode = CTLineBreakModeFromUILineBreakMode(self.lineBreakMode);
    CTTextAlignment alignment = CTTextAlignmentFromUITextAlignment(NSTextAlignmentCenter);
    
    //Apply paragraph settings
    CTParagraphStyleRef style = CTParagraphStyleCreate((CTParagraphStyleSetting[6]){
        {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment},
        {kCTParagraphStyleSpecifierMinimumLineHeight,sizeof(minimumLineHeight), &minimumLineHeight},
        {kCTParagraphStyleSpecifierMaximumLineHeight,sizeof(maximumLineHeight), &maximumLineHeight},
        {kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(linespace), &linespace},
        {kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(linespace), &linespace},
        {kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &lineBreakMode},
    }, 6);
    
    _selectedCoreTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)font, (NSString *)kCTFontAttributeName,
                                   _selectedTextColor.CGColor,kCTForegroundColorAttributeName,
                                   style,kCTParagraphStyleAttributeName,
                                   nil];
    
    _unselectedCoreTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)font, (NSString *)kCTFontAttributeName,_textColor.CGColor,kCTForegroundColorAttributeName,
                                     style,kCTParagraphStyleAttributeName,
                                     nil];
    
    CFRelease(font);
    CFRelease(style);
}

#pragma mark - setter and getter

- (void)setEnableLineWrap:(BOOL)enableLineWrap
{
    _enableLineWrap = enableLineWrap;
    
    [self setupCoreTextAttributes];
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
    
    [self setupCoreTextAttributes];
}

- (void)setSelectedTextColor:(UIColor *)selectedTextColor {
    _selectedTextColor = selectedTextColor;
    
    [self setupCoreTextAttributes];
}

- (void)setFont:(UIFont *)font {
    _font = font;
    
    [self setupCoreTextAttributes];
}

@end
