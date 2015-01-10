//
//  SettingsViewController.m
//  营内聊
//
//  Created by WuQiong on 14/11/13.
//  Copyright (c) 2014年 戴维营教育. All rights reserved.
//

#import "SettingsViewController.h"

#import "ServerManager.h"

@interface SettingsViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = @"退出登录";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[ServerManager sharedManager] logout];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *viewCtrl = [storyboard instantiateViewControllerWithIdentifier:kLoginControllerID];
    self.view.window.rootViewController = viewCtrl;
}
@end
