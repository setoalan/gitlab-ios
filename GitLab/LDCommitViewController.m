//
//  LDCommitViewController.m
//  GitLab
//
//  Created by Alan Seto on 8/11/14.
//  Copyright (c) 2014 Logicdrop. All rights reserved.
//

#import "LDCommitViewController.h"
#import "LDSession.h"
#import "LDCommitStore.h"
#import "LDDiffViewController.h"

@interface LDCommitViewController ()

@property (nonatomic) NSURLSession *urlSession;

@end

@implementation LDCommitViewController

- (instancetype)init:(NSString *)projectID commitTitle:(NSString *)title commitHash:(NSString *)hash
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.projectID = projectID;
        self.hash = hash;
        self.navigationItem.title = title;
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _urlSession = [NSURLSession sessionWithConfiguration:config
                                                    delegate:nil
                                               delegateQueue:nil];
        
        [self fetchCommit];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LDDiffViewController *diffViewController = [[LDDiffViewController alloc] init:indexPath];
    
    [self.navigationController pushViewController:diffViewController animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[LDCommitStore sharedStore] allItems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    cell.textLabel.text = [[[[LDCommitStore sharedStore] getItem:indexPath] objectForKey:@"new_path"] lastPathComponent];
    
    return cell;
}

- (void)fetchCommit
{
    LDSession *session = [LDSession sharedSession];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/api/v3/projects/%@/repository/commits/%@/diff?private_token=%@", session.hostURL, self.projectID, self.hash, session.privateToken];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:20.0];
    
    NSURLSessionDataTask *dataTask =
    [_urlSession dataTaskWithRequest:request
                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                       NSArray *jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                                             options:0
                                                                               error:nil];
                       [[LDCommitStore sharedStore] createStore:jsonObject];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self.tableView reloadData];
                       });
                   }];
    
    [dataTask resume];
}

@end
