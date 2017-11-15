//
//  ViewController.m
//  ZKInteractionOfOCAndJS
//
//  Created by Zhou Kang on 2017/11/14.
//  Copyright © 2017年 Zhou Kang. All rights reserved.
//

#import "ViewControllerForWKWeb.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <WebKit/WebKit.h>

#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewControllerForWKWeb () <WKUIDelegate, WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;

@end

static NSString *const kURLStr = @"http://192.168.70.142/webapps/JSFile/jsDemo_0.html";

@implementation ViewControllerForWKWeb

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupWebView];
    [self loadRequest];
    [self setupBtn];
}

- (void)setupBtn {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:@"Call JS" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    btn.frame = CGRectMake(30, 100, 100, 30);
    [btn addTarget:self action:@selector(callJS) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupWebView {
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight - 64.f)];
    [self.view insertSubview:_webView atIndex:0];
    _webView.UIDelegate = self;
    _webView.navigationDelegate = self;
}

- (void)loadRequest {
    NSURL *url = [NSURL URLWithString:kURLStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    [_webView loadRequest:request];
}

#pragma mark - <WKUIDelegate, WKNavigationDelegate>

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"%s", __func__);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"%s", __func__);
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"%s", __func__);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"%s", __func__);
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:@"提示"
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler();
                                                      }]];
    
    [self presentViewController:alertController animated:YES completion:^{}];
}

- (void)callJS {
    [_webView evaluateJavaScript:@"alertText('Call JS')" completionHandler:^(id _Nullable res, NSError * _Nullable error) {
        NSLog(@"from js => %@", (NSString *)res);
    }];
}

@end