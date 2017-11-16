//
//  ZKObjCModel.h
//  ZKInteractionOfOCAndJS
//
//  Created by Zhou Kang on 2017/11/16.
//  Copyright © 2017年 Zhou Kang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol ZKModelJSMethods <JSExport>

- (void)callCamera;
- (void)callOCWithParams:(NSDictionary *)params;

@end

@interface ZKObjCModel : NSObject <ZKModelJSMethods>

@property (nonatomic, weak) JSContext *jsContext;
@property (nonatomic, weak) UIWebView *webView;

@end
