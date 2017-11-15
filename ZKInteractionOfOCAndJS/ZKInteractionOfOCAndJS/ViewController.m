//
//  ViewController.m
//  ZKInteractionOfOCAndJS
//
//  Created by Zhou Kang on 2017/11/15.
//  Copyright © 2017年 Zhou Kang. All rights reserved.
//

#import "ViewController.h"
#import "ViewControllerForUIWeb.h"
#import "ViewControllerForWKWeb.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)toUIWeb {
    ViewControllerForUIWeb *vc = [ViewControllerForUIWeb new];
    [self.navigationController pushViewController:vc animated:true];
}

- (IBAction)toWKWeb {
    ViewControllerForWKWeb *vc = [ViewControllerForWKWeb new];
    [self.navigationController pushViewController:vc animated:true];
}

@end
