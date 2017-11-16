//
//  ViewControllerForUIWeb.m
//  ZKInteractionOfOCAndJS
//
//  Created by Zhou Kang on 2017/11/15.
//  Copyright © 2017年 Zhou Kang. All rights reserved.
//

#import "ViewControllerForUIWeb.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "ZKObjCModel.h"

@interface ViewControllerForUIWeb () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) JSContext *jsContent;

@end

static NSString *const kURLStr = @"http://192.168.70.142/webapps/JSFile/JSForUIWebView.html";

@implementation ViewControllerForUIWeb

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupWebView];
    [self loadRequest];
    [self setupBtn];
}

- (void)loadRequest {
    NSURL *URL = [NSURL URLWithString:kURLStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [_webView loadRequest:request];
}

- (void)setupWebView {
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight - 64.f)];
    [self.view addSubview:_webView];
    _webView.delegate = self;
}

- (void)setupBtn {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:@"App Call JS" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    btn.frame = CGRectMake(30, 100, 100, 30);
    [btn addTarget:self action:@selector(callJS) forControlEvents:UIControlEventTouchUpInside];
}

- (void)callJS {
    if (!_jsContent) {
        NSLog(@"jsContext has not fetched");
        return;
    }
    JSValue *alertFunc = _jsContent[@"alertMsg"];
    [alertFunc callWithArguments:@[ @"Call JS to alert" ]];
    // 或者可以直接用 stringByEvaluatingJSFromString: 即可
    // [_webView stringByEvaluatingJavaScriptFromString:@"alertMsg('Call JS')"];
}

#pragma mark - <UIWebViewDelegate>

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"%s", __func__);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"%s", __func__);
    // 注意这种获取 JSContext 的方法在 WKWebView 中就不能用了。
    _jsContent = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    ZKObjCModel *model = [ZKObjCModel new];
    _jsContent[@"ZKModel"] = model;
    model.jsContext = _jsContent;
    model.webView = webView;
    
    [_jsContent setExceptionHandler:^(JSContext *context, JSValue *exception) {
        context.exception = exception;
        NSLog(@"%@", exception);
    }];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"%s", __func__);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"%s", __func__);
    return true;
}

@end
