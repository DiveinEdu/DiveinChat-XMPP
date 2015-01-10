//
//  RegisterViewController.m
//  营内聊
//
//  Created by WuQiong on 14/11/13.
//  Copyright (c) 2014年 戴维营教育. All rights reserved.
//

#import "RegisterViewController.h"

#import "ServerManager.h"

#import "SVProgressHUD.h"

@interface RegisterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [ServerManager sharedManager].willStartRequest = ^(ServerState state){
        if (kRegisterServerState == state) {
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        }
    };
    
    [ServerManager sharedManager].didFinishedRequest = ^(ServerState state, RequestErrorCode code){
        [SVProgressHUD dismiss];
        
        if (kRegisterServerState == state && kRequestOK == code) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            self.view.window.rootViewController = [storyboard instantiateInitialViewController];
        }
        else {
            [SVProgressHUD showErrorWithStatus:@"注册失败，请检查网络"];
        }
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTap:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

//验证是否输入了用户名和密码
- (BOOL)validateInfo
{
    if (_nameTextField.text.length && _passTextField.text.length) {
        return YES;
    }
    
    return NO;
}

- (IBAction)didRegisterClicked:(UIButton *)sender {
    if ([self validateInfo]) {
        User *user = [[User alloc] init];
        user.username = _nameTextField.text;
        user.password = _passTextField.text;
        [[ServerManager sharedManager] registerUser:user];
    }
}
@end
