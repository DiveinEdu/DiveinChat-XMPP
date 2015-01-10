//
//  AddFriendViewController.m
//  营内聊
//
//  Created by WuQiong on 14/11/14.
//  Copyright (c) 2014年 戴维营教育. All rights reserved.
//

#import "AddFriendViewController.h"

#import "ServerManager.h"

@interface AddFriendViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@end

@implementation AddFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTap:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (IBAction)didAddClicked:(UIButton *)sender {
    if (_nameTextField.text.length) {
        User *user = [[User alloc] init];
        user.username = _nameTextField.text;
        [[ServerManager sharedManager] addFriend:user];
    }
}
@end
