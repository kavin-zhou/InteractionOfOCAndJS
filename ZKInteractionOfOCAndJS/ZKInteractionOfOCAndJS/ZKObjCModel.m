//
//  ZKObjCModel.m
//  ZKInteractionOfOCAndJS
//
//  Created by Zhou Kang on 2017/11/16.
//  Copyright © 2017年 Zhou Kang. All rights reserved.
//

#import "ZKObjCModel.h"

@implementation ZKObjCModel

- (void)callCamera {
    NSLog(@"打开系统相册");
}

- (void)callOCWithParams:(NSDictionary *)params {
    NSLog(@"%s with %@", __func__, params);
}

@end
