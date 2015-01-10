//
//  FriendsViewController.m
//  营内聊
//
//  XMMPP-iPhone框架中可以使用CoreData存储好友列表
//
//  Created by WuQiong on 14/11/13.
//  Copyright (c) 2014年 戴维营教育. All rights reserved.
//

#import "FriendsViewController.h"
#import "ChatViewController.h"

#import "ServerManager.h"

#import "XMPPFramework.h"
#import "DDLog+LOGV.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@import CoreData;

@interface FriendsViewController () <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSFetchedResultsController *_fetchedResultController;
    
    XMPPUserCoreDataStorageObject *_currentUser;
}
@property (weak, nonatomic) IBOutlet UITableView *friendsTableView;
@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    _fetchedResultController.delegate = nil;
}

//获取好友列表的结果控制对象
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultController == nil)
    {
        NSManagedObjectContext *moc = [[ServerManager sharedManager] rosterContext];
        
        //数据存储实体（表）
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
                                                  inManagedObjectContext:moc];
        
        //设置结果的排序规则
        NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
        NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
        
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, sd2, nil];
        
        //数据请求
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setFetchBatchSize:10];
        
        _fetchedResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                       managedObjectContext:moc
                                                                         sectionNameKeyPath:@"sectionNum"
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
    [_friendsTableView reloadData];
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self fetchedResultsController] sections].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = [[self fetchedResultsController] sections];
    
    if (section < [sections count])
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
        return sectionInfo.numberOfObjects;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    //获取用户信息
    XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    cell.textLabel.text = user.jid.user;
    if (user.photo != nil)
    {
        cell.imageView.image = user.photo;
    }
    else
    {
        //获取头像数据
        NSData *photoData = [[[ServerManager sharedManager] avatarModule] photoDataForJID:user.jid];
        
        if (photoData != nil)
            cell.imageView.image = [UIImage imageWithData:photoData];
        else
            cell.imageView.image = [UIImage imageNamed:@"Friends_head"];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //获取用户信息
    _currentUser = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    NSLog(@"%@", _currentUser);
    
    return indexPath;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"chatIdentifier"]) {
        ChatViewController *chatCtrl = segue.destinationViewController;
        chatCtrl.user = _currentUser;
    }
}
@end
