//
//  QuillView.h
//  quillview
//
//  Created by LIN on 2017/8/31.
//  Copyright © 2017年 hive. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QuillStyle;

@interface QuillView : UIView

@property (nonatomic, strong) QuillStyle *style;
@property (nonatomic, strong) NSString *contentString;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@interface QuillStyle : NSObject

@property (nonatomic, assign) CGFloat indent; // 缩进大小
@property (nonatomic, assign) CGFloat lineHeight; // 正文行高
@property (nonatomic, assign) UIEdgeInsets contentInset; // 全文边距
@property (nonatomic, assign) UIEdgeInsets textBlockInset; // 段落边距
@property (nonatomic, strong) UIColor *linkColor; // 超链接文字颜色
@property (nonatomic, strong) UIColor *linkUnderlineColor; // 超链接下划线颜色
@property (nonatomic, assign) CGFloat fontSize; // 正文字体大小
@property (nonatomic, assign) CGFloat h1FontSize; // h1字体大小
@property (nonatomic, assign) CGFloat h2FontSize; // h2字体大小
@property (nonatomic, assign) CGFloat h3FontSize; // h3字体大小
@property (nonatomic, assign) CGFloat h4FontSize; // h4字体大小
@property (nonatomic, assign) CGFloat h5FontSize; // h5字体大小
@property (nonatomic, assign) CGFloat h6FontSize; // h6字体大小
@property (nonatomic, assign) CGFloat smallFontSize;
@property (nonatomic, assign) CGFloat largeFontSize;
@property (nonatomic, assign) CGFloat hugeFontSize;

- (CGFloat)widthWithContainer:(UIView *)container;
- (CGFloat)heightWithContainer:(UIView *)container;
- (CGFloat)indentDistance:(NSUInteger)indentLevel;

@end

@interface QuillUtil : NSObject
+ (CGFloat)sizeWithAttr:(NSString *)attr basicSize:(CGFloat)basicSize;
+ (UIColor *)colorWithAttr:(NSString *)attr;
+ (NSString *)alphabetNumber:(NSInteger)num;
+ (NSString *)romanNumber:(NSInteger)num;
@end
