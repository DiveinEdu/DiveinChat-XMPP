//
//  AccountViewController.m
//  营内聊
//
//  Created by WuQiong on 14/11/14.
//  Copyright (c) 2014年 戴维营教育. All rights reserved.
//

#import "AccountViewController.h"

@interface AccountViewController ()

@end

@implementation AccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didKeyboardChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

//查找第一响应者
- (UIView *)findFirstResponder:(UIView *)view
{
    if ([view isFirstResponder])
    {
        return view; // Base case
    }
    
    for (UIView *subView in [view subviews])
    {
        if ([self findFirstResponder:subView])
        {
            return subView; // Recursion
        }
    }
    return nil;
}

////如果能够获取firstReponder最好...
//- (void)refreshUIWithKeyboard:(CGRect)frame duration:(CGFloat)duration
//{
//    
//}

//键盘变化
- (void)didKeyboardChangeFrame:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    
    //键盘尺寸
    NSValue *bFrame = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [bFrame CGRectValue];
    
    //动画时间
//    NSString *dStr = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
//    CGFloat duration = [dStr floatValue];
    
    CGRect rect = self.view.bounds;

    //键盘隐藏，视图恢复正常位置
    if (keyboardFrame.origin.y >= self.view.frame.size.height) {
        self.view.center = CGPointMake(rect.size.width/2, rect.size.height/2);
    }
    else {
        //查找第一响应者
        UIView *activeView = [self findFirstResponder:self.view];
        
        CGFloat delta = CGRectGetMaxY(activeView.frame) - keyboardFrame.origin.y;
        //如果键盘遮住输入框，整体上移
        if (delta > 0) {
            self.view.frame = CGRectMake(0, - delta - 10, self.view.frame.size.width, self.view.frame.size.height);
        }
        else {
            //回复正常位置
            self.view.center = CGPointMake(rect.size.width/2, rect.size.height/2);
        }
    }
}

@end
