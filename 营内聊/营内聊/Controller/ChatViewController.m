//
//  ChatViewController.m
//  营内聊
//
//  Created by WuQiong on 14/11/13.
//  Copyright (c) 2014年 戴维营教育. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "ChatViewController.h"
#import "ChatTableViewCell.h"

#import "ServerManager.h"
#import "AccountManager.h"

#import "DDLog.h"
#import "NSDate+Utilities.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface ChatViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>
{
    NSFetchedResultsController *_fetchedResultController;
    
    NSInteger _numberOfRows;
    
    UIImage *_incomingAvatar;
    UIImage *_outgoingAvatar;
}
@property (weak, nonatomic) IBOutlet UITableView *chatTableView;
@property (weak, nonatomic) IBOutlet UIView *inputView;
@property (weak, nonatomic) IBOutlet UITextField *sendTextField;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.title = _user.jid.user;
    
    //获取头像数据
    NSData *photoData = [[[ServerManager sharedManager] avatarModule] photoDataForJID:_user.jid];
    if (photoData != nil)
        _incomingAvatar = [UIImage imageWithData:photoData];
    else
        _incomingAvatar = [UIImage imageNamed:@"Friends_head"];
    
    XMPPJID *jid = [XMPPJID jidWithString:[AccountManager sharedManager].user.username];
    photoData = [[[ServerManager sharedManager] avatarModule] photoDataForJID:jid];
    if (photoData != nil)
        _outgoingAvatar = [UIImage imageWithData:photoData];
    else
        _outgoingAvatar = [UIImage imageNamed:@"Friends_head"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didKeyboardChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [self controllerDidChangeContent:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)dealloc
{
    _fetchedResultController.delegate = nil;
}

- (IBAction)didTypeClicked:(UIButton *)sender {
    _inputView.hidden = NO;
    [_sendTextField becomeFirstResponder];
}

- (IBAction)didSendClicked:(UIButton *)sender {
    Message *message = [[Message alloc] init];
    message.body = _sendTextField.text;
    
    User *user = [[User alloc] init];
    user.username = _user.jid.user;
    [[ServerManager sharedManager] sendMessage:message toUser:user];
    
    _sendTextField.text = nil;
}

- (IBAction)didTap:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
    _inputView.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
        self.view.frame = CGRectMake(0, 0, rect.size.width, rect.size.height + keyboardFrame.size.height);
    }
    else {
        
        self.view.frame = CGRectMake(0, 0, rect.size.width, rect.size.height - keyboardFrame.size.height);
    }
}

//获取好友列表的结果控制对象
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultController == nil)
    {
        NSManagedObjectContext *moc = [[ServerManager sharedManager] messageContext];
        
        //数据存储实体（表）
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject"
                                                  inManagedObjectContext:moc];
        
        //设置结果的排序规则
        NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
        
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sd, nil];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr=%@", _user.jidStr];
        
        //数据请求
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setFetchBatchSize:10];
        
        _fetchedResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                       managedObjectContext:moc
                                                                         sectionNameKeyPath:nil
                                                                                  cacheName:nil];
        [_fetchedResultController setDelegate:self];
        
        
        NSError *error = nil;
        //开始请求数据
        if (![_fetchedResultController performFetch:&error])
        {
            DDLogError(@"Error performing fetch: %@", error);
        }
        
    }
    
    return _fetchedResultController;
}

//数据改变
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [_chatTableView reloadData];
    
    //尝试滚动到最底下
    if (_numberOfRows) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_numberOfRows - 1 inSection:0];
        [_chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = [[self fetchedResultsController] sections];
    
    if (section < [sections count])
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
        _numberOfRows = sectionInfo.numberOfObjects;
        return sectionInfo.numberOfObjects;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMPPMessageArchiving_Message_CoreDataObject *message = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    ChatTableViewCell *cell = nil;
    if (message.isOutgoing) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"outgoing" forIndexPath:indexPath];
        cell.avatarImageView.image = _outgoingAvatar;
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"incoming" forIndexPath:indexPath];
        cell.avatarImageView.image = _incomingAvatar;
    }
    
    cell.messageLabel.text = message.body;
    cell.timeLabel.text = message.timestamp.shortTimeString;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMPPMessageArchiving_Message_CoreDataObject *message = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    NSString *str = message.body;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByWordWrapping;
    style.alignment = NSTextAlignmentLeft;
    
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:17], NSParagraphStyleAttributeName:style};
    CGSize size = [str sizeWithAttributes:dict];
    
    CGSize vSize = self.view.bounds.size;
    //只有一行
    if (vSize.width - 120 >= size.width) {
        return 56 + size.height + 14;
    }
    else {
        CGRect rect = [str boundingRectWithSize:CGSizeMake(vSize.width - 120, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:NULL];
        
        return 56 + rect.size.height + 14;
    }
}
@end
