//
//  LoginViewController.m
//  营内聊
//
//  Created by WuQiong on 14/11/13.
//  Copyright (c) 2014年 戴维营教育. All rights reserved.
//

#import "LoginViewController.h"

#import "ServerManager.h"

#import "SVProgressHUD.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [ServerManager sharedManager].willStartRequest = ^(ServerState state){
        if (kLoginServerState == state) {
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        }
    };
    
    [ServerManager sharedManager].didFinishedRequest = ^(ServerState state, RequestErrorCode code){
        [SVProgressHUD dismiss];
        
        if (kLoginServerState == state && kRequestOK == code) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            self.view.window.rootViewController = [storyboard instantiateInitialViewController];
        }
        else {
            [SVProgressHUD showErrorWithStatus:@"登录失败，请检查你的用户名和密码"];
        }
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//验证是否输入了用户名和密码
- (BOOL)validateInfo
{
    if (_nameTextField.text.length && _passTextField.text.length) {
        return YES;
    }
    
    return NO;
}

//开始登录
- (IBAction)didLoginClicked:(UIButton *)sender {
    if ([self validateInfo]) {
        User *user = [[User alloc] init];
        user.username = _nameTextField.text;
        user.password = _passTextField.text;
        [[ServerManager sharedManager] login:user];
    }
}

//单击隐藏键盘
- (IBAction)didTap:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (IBAction)unwindFromRegister:(UIStoryboardSegue *)sender
{
    
}


@end
