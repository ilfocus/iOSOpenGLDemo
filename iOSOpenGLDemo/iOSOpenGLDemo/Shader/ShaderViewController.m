//
//  ShaderViewController.m
//  iOSOpenGLDemo
//
//  Created by WangQi on 2019/10/16.
//  Copyright © 2019 $(PRODUCT_NAME). All rights reserved.
//

#import "ShaderViewController.h"
#import "ShaderView.h"
#import "LearnView.h"

@interface ShaderViewController ()
@property (nonatomic, strong) ShaderView *shaderView;
@property (nonatomic, strong) LearnView *learnView;
@end

@implementation ShaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//	self.shaderView = (ShaderView *)self.view;
//	self.shaderView = [[ShaderView alloc] init];
//	self.shaderView.frame = CGRectMake(0, kTopHeight, kScreenWidth, kScreenHeight);
//	[self.view addSubview:self.shaderView];
	
	self.learnView = [[LearnView alloc] init];
	self.learnView.frame = CGRectMake(0, kTopHeight, kScreenWidth, kScreenHeight);
	[self.view addSubview:self.learnView];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
