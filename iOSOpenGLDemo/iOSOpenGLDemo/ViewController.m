//
//  ViewController.m
//  iOSOpenGLDemo
//
//  Created by WangQi on 2019/10/16.
//  Copyright © 2019 $(PRODUCT_NAME). All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *listArray;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"iOSOpenGLDemo";
	
	[self.view addSubview:self.tableView];
	
	self.listArray = [self readLocalFileWithName:@"listChart"];
}
- (NSArray *)readLocalFileWithName:(NSString *)name
{
    // 获取文件路径
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    // 将文件数据化
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    
    return [NSJSONSerialization JSONObjectWithData:data
                                           options:kNilOptions
                                             error:nil];
}
#pragma mark - table datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.listArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CELL = @"CELL";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:CELL];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	NSDictionary *dic = self.listArray[indexPath.row];
	cell.textLabel.text = dic[@"title"];
	return cell;
}
#pragma mark - tableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	NSDictionary *dic = self.listArray[indexPath.row];
	NSString *vcString = dic[@"ViewController"];
	UIViewController *vc = [[NSClassFromString(vcString) alloc] init];
	if (!vc) {
		NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
		NSString *app_Name = [infoDictionary objectForKey:@"CFBundleName"];
		
		NSString *swiftVCName = [NSString stringWithFormat:@"%@.%@",app_Name,vcString];
		vc = [[NSClassFromString(swiftVCName) alloc] init];
		if (!vc) {
			NSString *message = [NSString stringWithFormat:@"缺少控制器%@",vcString];
			UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"找不到控制器"
																		   message:message
																	preferredStyle:UIAlertControllerStyleAlert];
			UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
																  handler:^(UIAlertAction * action) {
																  }];

			[alert addAction:defaultAction];
			[self presentViewController:alert animated:YES completion:nil];
			return;
		}
	}
	[self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - sets and gets
- (UITableView *)tableView {
	if (!_tableView) {
		CGRect rect = CGRectMake(0, kTopHeight, kScreenWidth, kScreenHeight - kTopHeight);
		_tableView = [[UITableView alloc] initWithFrame:rect style:(UITableViewStylePlain)];
		_tableView.backgroundColor = [UIColor clearColor];
		_tableView.delegate = self;
		_tableView.dataSource = self;
		_tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

	}
	return _tableView;
}
- (NSArray *)listArray {
	if (!_listArray) {
		_listArray = [[NSArray alloc] init];
	}
	return _listArray;
}
@end
