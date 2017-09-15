//
//  EditorViewController.m
//  quillview
//
//  Created by LIN on 2017/9/7.
//  Copyright © 2017年 hive. All rights reserved.
//

#import "EditorViewController.h"

#import "Masonry.h"
#import "DetailViewController.h"
#import "ViewController.h"

#define EDITOR_URL @"http://quilljs.com/standalone/full/"

@interface EditorViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIButton *previewButton;
@property (nonatomic, strong) UIButton *resetButton;
@property (nonatomic, strong) UIButton *backButton;

@end

@implementation EditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _webView = [[UIWebView alloc] init];
    _webView.dataDetectorTypes = UIDataDetectorTypeNone;
    [self.view addSubview:_webView];
    [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.top.equalTo(self.view).offset(20);
        make.width.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    _webView.delegate = self;
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:EDITOR_URL]]];
    _webView.userInteractionEnabled = NO;
    
    UIView *bottomBar = [UIView new];
    bottomBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomBar];
    [bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.width.equalTo(self.view);
        make.top.equalTo(self.view.mas_bottom).offset(-100);
    }];
    
    _resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _resetButton.enabled = NO;
    [_resetButton setTitle:@"Reset" forState:UIControlStateNormal];
    [_resetButton addTarget:self action:@selector(reset) forControlEvents:UIControlEventTouchUpInside];
    [bottomBar addSubview:_resetButton];
    [_resetButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bottomBar).offset(20);
        make.bottom.equalTo(bottomBar).offset(-50);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(44);
    }];
    
    _previewButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _previewButton.enabled = NO;
    [_previewButton setTitle:@"Preview with QuillView" forState:UIControlStateNormal];
    [_previewButton addTarget:self action:@selector(preview) forControlEvents:UIControlEventTouchUpInside];
    [bottomBar addSubview:_previewButton];
    [_previewButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(bottomBar).offset(-20);
        make.bottom.equalTo(bottomBar).offset(-50);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
    }];
    
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
    ViewController *vc = [[ViewController alloc] init];
    [UIApplication sharedApplication].keyWindow.rootViewController = vc;
}

- (void)reset
{
    [_webView stringByEvaluatingJavaScriptFromString:@"quill.setContents([])"];
}

- (void)preview
{
    NSString *contents = [_webView stringByEvaluatingJavaScriptFromString:@"JSON.stringify(quill.getContents())"];
    if (contents.length > 0) {
        NSLog(@"%@", contents);
        
        DetailViewController *vc = [[DetailViewController alloc] init];
        vc.contents = contents;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    _webView.userInteractionEnabled = YES;
    _previewButton.enabled = YES;
    _resetButton.enabled = YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
