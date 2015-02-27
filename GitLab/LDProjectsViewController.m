//
//  LDProjectsViewController.m
//  GitLab
//
//  Created by Alan Seto on 7/16/14.
//  Copyright (c) 2014 Logicdrop. All rights reserved.
//

#import "LDProjectsViewController.h"
#import "LDSession.h"
#import "LDProjectsCell.h"
#import "LDCommitsViewController.h"
#import "LDIssuesViewController.h"
#import "LDMergeRequestsViewController.h"

@interface LDProjectsViewController ()
{
    NSIndexPath *curIndex;
    NSString *curBranch;
}

@property (nonatomic) NSURLSession *urlSession;
@property (nonatomic) NSString *projectID;

@end

@implementation LDProjectsViewController

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.navigationItem.title = @"Projects";
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _urlSession = [NSURLSession sessionWithConfiguration:config
                                                 delegate:nil
                                            delegateQueue:nil];
        [self fetchProjects];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:@"LDProjectsCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"LDProjectsCell"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.projects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"LDProjectsCell";
    
    LDProjectsCell *cell = (LDProjectsCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }

    NSDictionary *project = self.projects[indexPath.row];
    
    cell.projectName.text = [project objectForKey:@"name_with_namespace"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.000Z"];
    NSDate *date = [dateFormatter dateFromString:[project objectForKey:@"last_activity_at"]];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit) fromDate:date toDate:[NSDate date] options:0] ;
    if (components.year > 0) {
        if (components.month > 6) {
            cell.lastActivity.text = [NSString stringWithFormat:@"Last activity: %d years ago", components.year + 1];
        } else {
            if (components.year == 1) {
                cell.lastActivity.text = @"Last activity: a year ago";
            } else {
                cell.lastActivity.text = [NSString stringWithFormat:@"Last activity: %d years ago", components.year];
            }
        }
    } else if (components.month > 0) {
        if (components.day > 15) {
            cell.lastActivity.text = [NSString stringWithFormat:@"Last activity: %d months ago", components.month + 1];
        } else {
            if (components.month == 1) {
                cell.lastActivity.text = @"Last activity: about a month ago";
            } else {
                cell.lastActivity.text = [NSString stringWithFormat:@"Last activity: %d months ago", components.month];
            }
        }
    } else if (components.day > 0) {
        if (components.hour > 12) {
            cell.lastActivity.text = [NSString stringWithFormat:@"Last activity: %d days ago", components.day + 1];
        } else {
            if (components.day == 1) {
                cell.lastActivity.text = @"Last activity: a day ago";
            } else {
                cell.lastActivity.text = [NSString stringWithFormat:@"Last activity: %d days ago", components.day];
            }
        }
    } else if (components.hour > 0) {
        if (components.minute > 30) {
            cell.lastActivity.text = [NSString stringWithFormat:@"Last activity: about %d hours ago", components.hour + 1];
        } else {
            if (components.hour == 1) {
                cell.lastActivity.text = @"Last activity: about an hour ago";
            } else {
                cell.lastActivity.text = [NSString stringWithFormat:@"Last activity: about %d hours ago", components.hour];
            }
        }
    } else if (components.minute > 0) {
        if (components.second > 30) {
            cell.lastActivity.text = [NSString stringWithFormat:@"Last activity: %d minutes ago", components.minute + 1];
        } else {
            if (components.minute == 1) {
                cell.lastActivity.text = @"Last activity: a minute ago";
            } else {
                cell.lastActivity.text = [NSString stringWithFormat:@"Last activity: %d minutes ago", components.minute];
            }
        }
    } else {
        cell.lastActivity.text = @"Last activity: a few seconds ago";
    }

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *project = self.projects[indexPath.row];
    
    self.projectID = [project objectForKey:@"id"];
    curIndex = indexPath;
    curBranch = @"master";
    
    LDCommitsViewController *commitsViewController = [[LDCommitsViewController alloc] init:[project objectForKey:@"name_with_namespace"] projectIdentification:[project objectForKey:@"id"] branch:@"master"];
    LDIssuesViewController *issuesViewController = [[LDIssuesViewController alloc] init:[project objectForKey:@"id"]];
    LDMergeRequestsViewController *mergeRequestsViewController = [[LDMergeRequestsViewController alloc] init:[project objectForKey:@"id"]];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[commitsViewController, issuesViewController, mergeRequestsViewController];
    tabBarController.tabBar.translucent = NO;
    tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(changeBranch)];
    
    [self fetchProjectBranches];
    
    [self.navigationController pushViewController:tabBarController animated:YES];
}

- (void)changeBranch
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Change Branch"
                                                      message:nil
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:nil];
    
    for (int i=0; i<[self.branches count]; i++) {
        [message addButtonWithTitle:[[self.branches objectAtIndex:i] objectForKey:@"name"]];
    }
    
    [message show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([curBranch isEqualToString:[alertView buttonTitleAtIndex:buttonIndex]] || buttonIndex == 0) {
        return;
    }
    
    [self.navigationController popViewControllerAnimated:NO];
    
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];    
    NSDictionary *project = self.projects[curIndex.row];
    
    self.projectID = [project objectForKey:@"id"];
    curBranch = title;
    
    LDCommitsViewController *commitsViewController = [[LDCommitsViewController alloc] init:[project objectForKey:@"name_with_namespace"] projectIdentification:[project objectForKey:@"id"] branch:title];
    LDIssuesViewController *issuesViewController = [[LDIssuesViewController alloc] init:[project objectForKey:@"id"]];
    LDMergeRequestsViewController *mergeRequestsViewController = [[LDMergeRequestsViewController alloc] init:[project objectForKey:@"id"]];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[commitsViewController, issuesViewController, mergeRequestsViewController];
    tabBarController.tabBar.translucent = NO;
    tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(changeBranch)];
    
    [self fetchProjectBranches];
    
    [self.navigationController pushViewController:tabBarController animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66;
}

- (void)fetchProjects
{
    LDSession *session = [LDSession sharedSession];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/api/v3/projects?private_token=%@", session.hostURL, session.privateToken];
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
                      self.projects = jsonObject;
                      
                      dispatch_async(dispatch_get_main_queue(), ^{
                          [self.tableView reloadData];
                      });
                  }];
    
    [dataTask resume];
}

- (void)fetchProjectBranches
{
    LDSession *session = [LDSession sharedSession];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/api/v3/projects/%@/repository/branches?private_token=%@", session.hostURL, self.projectID, session.privateToken];
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
                       self.branches = jsonObject;
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self.tableView reloadData];
                       });
                   }];
    
    [dataTask resume];
}

@end
