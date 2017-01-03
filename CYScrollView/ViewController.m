//
//  ViewController.m
//  CYScrollView
//
//  Created by yengod on 16/9/21.
//  Copyright © 2016年 yenge. All rights reserved.
//

#import "ViewController.h"
#import "CYCirculationScrollView.h"
#import <Masonry.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CYCirculationScrollView *scrollView = [[CYCirculationScrollView alloc]initWithImageNames:@[@"1",@"2",@"3"] autoScroll:YES repeat:YES];
    scrollView.imageContentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
