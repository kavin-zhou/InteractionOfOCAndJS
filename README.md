#### JS 交互
###### App 调用 JS
通过`webView evaluateJavaScript:completionHandler:`完成调用 JS 代码。在 UIWebView 的时候是`webView stringByEvaluatingJavaScriptFromString:`。基本一样，前者多了可以拿到调用 JS 后返回的数据。注意是同步的。如下代码：
```
- (void)callJS {
    [_webView evaluateJavaScript:@"alertText('Call JS')" completionHandler:^(id _Nullable res, NSError * _Nullable error) {
        NSLog(@"from js => %@", (NSString *)res);
    }];
}
```
如果想用 App 插入 JS 一段代码，例如改变背景色，上面这种解决方法就可以。如下：
```
[_webView evaluateJavaScript:@"function changeBG(){document.body.style.background = '#333';} changeBG();" completionHandler:nil];
```
当然，上面这种不是最好的方法，在初始化 WKWebView 的时候，通过 WKWebViewConfiguration 就可以注入一段 JS 代码，并且可以指定注入时间。具体如下
```
WKUserScript *script = [[WKUserScript alloc] initWithSource:@"document.body.style.background = '#666';" injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:true];
WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
[config.userContentController addUserScript:script];
_webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight - 64.f) configuration:config];

```
###### JS 调用 OC
UIwebView 没有 JS 调 App 的方法，而在 WKWebView 中有了改进。可以使用 `WKScriptMessageHandler` 完成交互。一共分为三个步骤：
1、 App 注册 Handler
```
WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
[config.userContentController addScriptMessageHandler:self name:@"openCameraHandler"];
[config.userContentController addScriptMessageHandler:self name:@"downloadImgHandler"];
```
2、App 实现<WKScriptMessageHandler>代理方法，即`didReceiveScriptMessage:`
```
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {

    if ([message.name isEqualToString:@"openCameraHandler"]) {
        NSLog(@"open camera in app");
    }
    else if ([message.name isEqualToString:@"downloadImgHandler"]) {
        NSDictionary *dict = (NSDictionary *)message.body;
        NSString *methodStr = dict[@"method"];
        NSString *paramStr = dict[@"param"];
        NSLog(@"method: %@  param: %@", methodStr, paramStr);
    }
}
```

3、js 调用 ```
window.webkit.messageHandlers.openCameraHandler.postMessage('');

```
