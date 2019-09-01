### WKWebView 的 JS 交互
#### App 调用 JS
通过`webView evaluateJavaScript:completionHandler:`完成调用 JS 代码。在 UIWebView 的时候是`webView stringByEvaluatingJavaScriptFromString:`。基本一样，前者多了可以拿到调用 JS 后返回的数据。注意是同步的。如下代码：
```
// code in App
- (void)callJS {
    [_webView evaluateJavaScript:@"alertText('Call JS')" completionHandler:^(id _Nullable res, NSError * _Nullable error) {
        NSLog(@"from js => %@", (NSString *)res);
    }];
}

// code in JS
function alertText(text) {
    console.log(text);
    alert(text);
    return text;
}
```
如果想用 App 插入 JS 一段代码，例如改变背景色，上面这种解决方法就可以。如下：
```
[_webView evaluateJavaScript:@"function changeBG(){document.body.style.background = '#333';} changeBG();" completionHandler:nil];
```
当然，上面这种不是最好的方法，在初始化 WKWebView 的时候，通过 WKWebViewConfiguration 就可以注入一段 JS 代码，WKUserScript 允许在正文加载之前或之后注入到页面中。这个强大的功能允许在页面中以安全且唯一的方式操作网页内容。具体如下
```
WKUserScript *script = [[WKUserScript alloc] initWithSource:@"document.body.style.background = '#666';" injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:true];
WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
[config.userContentController addUserScript:script];
_webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight - 64.f) configuration:config];

```
#### JS 调用 App
考虑到 H5 页面的功能的局限性以及体验效果等，我们会经常有 H5 页面调用 App 原生接口的需求。即 JS 调用 App，我们以 JS 调用 OC 代码为例。交互方案如下
##### 1、拦截协议
通常的做法也是比较容易想到的方案就是拦截协议。简而言之就是在 H5 的某个事件后发送新的页面请求，即`location.href`，然后在 App 端的代理方法中拦截约定协议来做相关的操作。具体代码如下：
```
// code in JS
function jumpToLoginPage() {
    location.href = 'login://';
    // window.open('login://');
}
```
##### 2、WK 的 `WKScriptMessageHandler`
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

3、js 调用
```
window.webkit.messageHandlers.openCameraHandler.postMessage('');
```
### UIWebView 的 JS 交互
JavaScriptCore 一个 iOS7 引进的标准库。下面就来使用一个这个类库来完成 JS 交互功能。
我们先来认识一下几个概念，
- ** JSContext ** ：给 JS 提供运行的上下文环境，通过 `evaluateScript:`可以执行 JS 代码。相当于 H5 里面的全局对象 - `window`。
- ** JSValue ** ：封装了 JS 与 ObjC 中对应的类型，以及调用 JS 的 API 等。
- ** JSExport ** ：这是一个协议，如果采用协议的方法交互，自己定义的协议必须遵守此协议，在协议中声明的API都会在JS中暴露出来，才能调用。
- ** JSManagedValue ** ：管理数据和方法的类。
#### App 调用 JS
看下面代码
```
// code in js
<script type="text/javascript">
function alertMsg(text) {
    alert(text);
}
</script>
// code in iOS
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"%s", __func__);
    // 先获取到上下文环境，这样才能拿到 JS 中的全局函数或者属性进行操作
    _jsContent = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
}
// 然后通过 JSValue 进行函数的调用，如下
JSValue *alertFunc = _jsContent[@"alertMsg"];
[alertFunc callWithArguments:@[ @"Call JS to alert" ]];
// 或者可以直接用 stringByEvaluatingJSFromString: 即可
// [_webView stringByEvaluatingJavaScriptFromString:@"alertMsg('Call JS')"];
```
#### JS 调用 App
###### 直接输入函数到 JS
很简单，直接上代码
```
// code in js
<input type="button" value="callOCWithBlock" onclick="callOCWithBlock('zhoukang')">

// code in oc
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"%s", __func__);
    // 注意这种获取 JSContext 的方法在 WKWebView 中就不能用了。替换方法详见见 WKWebView 中 的 userContentController。
    _jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    [self injectMethodsIntoJS];
}
/** 通过注入函数来完成 JS 调用 App */
- (void)injectMethodsIntoJS {
    _jsContext[@"callOCWithBlock"] = ^() {
        NSArray *args = [JSContext currentArguments];
        NSLog(@"JS Call OC with args ==> %@", args);
    };
}
```
这种方式是没有注入模型到 JS 中的。这种方式使用起来不太合适，通常在 JS 中有很多全局的函数，为了防止名字重名，使用模型的方式是最好不过了。通过我们协商好的模型名称，在 JS 中直接通过模型来调用我们在 ObjC 中所定义的模型所公开的 API。
###### 注入模型
首先定义好 JS 要调用的 OC 的函数，我们可以通过协议来完成工作。这个协议也要继承自<JSExport>，否则在 JS 中无法知道在 App 中定义了哪些可以调用的方法。我们参考 JSExport 的官方文档，代码如下
在协议中声明在 JS 中可以调用的方法
```
@protocol ZKModelJSMethods <JSExport>
- (void)callCamera;
- (void)callOCWithParams:(NSDictionary *)params;
@end
```
构建模型，实现相应方法
```
@interface ZKObjCModel : NSObject <ZKModelJSMethods>
@property (nonatomic, weak) JSContext *jsContext;
@property (nonatomic, weak) UIWebView *webView;
@end

@implementation ZKObjCModel
- (void)callCamera {
    NSLog(@"打开系统相册");
}
- (void)callOCWithParams:(NSDictionary *)params {
    NSLog(@"%s with %@", __func__, params);
}
@end
```
然后在`webViewDidFinishLoad`中注入模型
```
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"%s", __func__);
    // 注意这种获取 JSContext 的方法在 WKWebView 中就不能用了。替换方法详见见 WKWebView 中 的 userContentController。
    _jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    ZKObjCModel *model = [ZKObjCModel new];
    _jsContext[@"ZKModel"] = model;
    
    [_jsContext setExceptionHandler:^(JSContext *context, JSValue *exception) {
        context.exception = exception;
        NSLog(@"%@", exception);
    }];
}
```
最后，在 Web 端直接调用即可
```
<input type="button" value="callOCWithModel0" onclick="ZKModel.callCamera()">
<input type="button" value="callOCWithModel1" onclick="ZKModel.callOCWithParams({'name':'zhoujielun'})">
```
