//
//  DetailViewController.m
//  quillview
//
//  Created by LIN on 2017/9/7.
//  Copyright © 2017年 hive. All rights reserved.
//

#import "DetailViewController.h"

#import "Masonry.h"
#import "QuillView.h"
#import "CSSStyleSheet.h"

@interface DetailViewController ()

@property (nonatomic, strong) QuillView *quillView;
@property (nonatomic, strong) UIButton *backButton;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _quillView = [[QuillView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_quillView];
    [_quillView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.top.equalTo(self.view).offset(20);
        make.width.equalTo(self.view);
        make.height.equalTo(self.view).offset(-20);
    }];
    
    _quillView.contentString = _contents;
    _quillView.style = [self quillStyleWithCSS:@"quill.snow.css"];
    
    _backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_backButton setTitle:@"back" forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backButton];
    [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(8);
        make.bottom.equalTo(self.view).offset(-8);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(44);
    }];
}

- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setContents:(NSString *)contents
{
    _contents = contents;
    _quillView.contentString = contents;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (QuillStyle *)quillStyleWithCSS:(NSString *)filename
{
    CSSStyleSheet *css = [CSSStyleSheet new];
    [css parseFile:filename];
    [css ensureRuleSet];
    
    QuillStyle *style = [QuillStyle new];
    id styleDict = [css styleForString:@"ql-container"];
    if (styleDict[@"font-size"]) {
        style.fontSize = [QuillUtil sizeWithAttr:styleDict[@"font-size"] basicSize:style.fontSize];
    }
    
    styleDict = [css styleForString:@"ql-editor"];
    if (styleDict[@"line-height"]) {
        style.lineHeight = [styleDict[@"line-height"] floatValue];
    }
    
    styleDict = [css styleForTag:@"h1" classNames:@[@"ql-editor",@"ql-snow"]];
    if (styleDict[@"font-size"]) {
        style.h1FontSize = [QuillUtil sizeWithAttr:styleDict[@"font-size"] basicSize:style.fontSize];
    }
    
    styleDict = [css styleForTag:@"h2" classNames:@[@"ql-editor",@"ql-snow"]];
    if (styleDict[@"font-size"]) {
        style.h2FontSize = [QuillUtil sizeWithAttr:styleDict[@"font-size"] basicSize:style.fontSize];
    }
    
    styleDict = [css styleForTag:@"h3" classNames:@[@"ql-editor",@"ql-snow"]];
    if (styleDict[@"font-size"]) {
        style.h3FontSize = [QuillUtil sizeWithAttr:styleDict[@"font-size"] basicSize:style.fontSize];
    }
    
    styleDict = [css styleForTag:@"h4" classNames:@[@"ql-editor",@"ql-snow"]];
    if (styleDict[@"font-size"]) {
        style.h4FontSize = [QuillUtil sizeWithAttr:styleDict[@"font-size"] basicSize:style.fontSize];
    }
    
    styleDict = [css styleForTag:@"h5" classNames:@[@"ql-editor",@"ql-snow"]];
    if (styleDict[@"font-size"]) {
        style.h5FontSize = [QuillUtil sizeWithAttr:styleDict[@"font-size"] basicSize:style.fontSize];
    }
    
    styleDict = [css styleForTag:@"h6" classNames:@[@"ql-editor",@"ql-snow"]];
    if (styleDict[@"font-size"]) {
        style.h6FontSize = [QuillUtil sizeWithAttr:styleDict[@"font-size"] basicSize:style.fontSize];
    }
    
    styleDict = [css styleForClassNames:@[@"ql-editor", @"ql-size-small"]];
    if (styleDict[@"font-size"]) {
        style.smallFontSize = [QuillUtil sizeWithAttr:styleDict[@"font-size"] basicSize:style.fontSize];
    }
    
    styleDict = [css styleForClassNames:@[@"ql-editor", @"ql-size-large"]];
    if (styleDict[@"font-size"]) {
        style.largeFontSize = [QuillUtil sizeWithAttr:styleDict[@"font-size"] basicSize:style.fontSize];
    }
    
    styleDict = [css styleForClassNames:@[@"ql-editor", @"ql-size-huge"]];
    if (styleDict[@"font-size"]) {
        style.hugeFontSize = [QuillUtil sizeWithAttr:styleDict[@"font-size"] basicSize:style.fontSize];
    }
    
    styleDict = [css styleForTag:@"a" classNames:@[@"ql-editor",@"ql-snow"]];
    id underlineStyle = styleDict[@"text-decoration"];
    if ([underlineStyle isEqualToString:@"none"]) {
        style.linkUnderlineColor = [UIColor clearColor];
    }
    else if ([underlineStyle isEqualToString:@"underline"]) {
        id underlineColor = styleDict[@"color"];
        if (underlineColor) {
            style.linkColor = [QuillUtil colorWithAttr:underlineColor];
        }
    }
    
    styleDict = [css styleForTag:@"p" classNames:@[@"ql-editor"]];
    if (styleDict[@"margin"]) {
        // TODO: 段落边距
    }
    
    // TODO: 全文边距
    
    NSLog(@"%@", styleDict);
    return style;
}

@end
