//
//  ViewControllerForUIWeb.m
//  ZKInteractionOfOCAndJS
//
//  Created by Zhou Kang on 2017/11/15.
//  Copyright © 2017年 Zhou Kang. All rights reserved.
//

#import "ViewControllerForUIWeb.h"

@interface ViewControllerForUIWeb () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation ViewControllerForUIWeb

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupWebView];
}

- (void)setupWebView {
    _webView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:_webView];
    _webView.delegate = self;
}

#pragma mark - <UIWebViewDelegate>

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"%s", __func__);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"%s", __func__);
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"%s", __func__);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"%s", __func__);
    return true;
}

@end
