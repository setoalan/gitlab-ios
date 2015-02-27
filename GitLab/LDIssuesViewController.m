//
//  LDIssuesViewController.m
//  GitLab
//
//  Created by Alan Seto on 7/18/14.
//  Copyright (c) 2014 Logicdrop. All rights reserved.
//

#import "LDIssuesViewController.h"
#import "LDIssuesCell.h"
#import "LDSession.h"
#import "LDIssueStore.h"
#import "LDIssueViewController.h"

@interface LDIssuesViewController ()

@property (nonatomic) NSURLSession *urlSession;

@end

@implementation LDIssuesViewController

- (instancetype)init:(NSString *)projectID
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.projectID = projectID;
        self.tabBarItem.title = @"Issues";
        self.tabBarItem.image = [UIImage imageNamed:@"issues"];
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _urlSession = [NSURLSession sessionWithConfiguration:config
                                                    delegate:nil
                                               delegateQueue:nil];
        
        [self fetchIssues];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:@"LDIssuesCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"LDIssuesCell"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LDIssueViewController *issueViewController = [[LDIssueViewController alloc] init:self.projectID issueID:[[[LDIssueStore sharedStore] getItem:indexPath] objectForKey:@"id"] issueIID:[[[LDIssueStore sharedStore] getItem:indexPath] objectForKey:@"iid"] title:[[[LDIssueStore sharedStore] getItem:indexPath] objectForKey:@"title"]];
    
    [self.navigationController pushViewController:issueViewController animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[LDIssueStore sharedStore] allItems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"LDIssuesCell";
    
    LDIssuesCell *cell = (LDIssuesCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.issueID.text = [NSString stringWithFormat:@"#%@", [[[LDIssueStore sharedStore] getItem:indexPath] objectForKey:@"iid"]];
    cell.title.font = [UIFont boldSystemFontOfSize:12];
    cell.title.text = [[[LDIssueStore sharedStore] getItem:indexPath] objectForKey:@"title"];
    if ([[[[LDIssueStore sharedStore] getItem:indexPath] objectForKey:@"state"] isEqualToString:@"opened"] ||
        [[[[LDIssueStore sharedStore] getItem:indexPath] objectForKey:@"state"] isEqualToString:@"reopened"]) {
        cell.state.textColor = [UIColor colorWithRed:0 green:200.0f/255.0f blue:0 alpha:1];
        cell.state.text = @"Open";
    } else {
        cell.state.textColor = [UIColor redColor];
        cell.state.text = @"Closed";
    }
    if ([[[LDIssueStore sharedStore] getItem:indexPath] objectForKey:@"assignee"] != [NSNull null]) {
        cell.assignee.text = [NSString stringWithFormat:@"assigned to %@", [[[[LDIssueStore sharedStore] getItem:indexPath] objectForKey:@"assignee"] objectForKey:@"name"]];
    } else {
        cell.assignee.text = @"unassigned";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.000Z"];
    NSDate *date = [dateFormatter dateFromString:[[[LDIssueStore sharedStore] getItem:indexPath] objectForKey:@"updated_at"]];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit) fromDate:date toDate:[NSDate date] options:0] ;
    if (components.year > 0) {
        if (components.month > 6) {
            cell.update.text = [NSString stringWithFormat:@"updated %d years ago", components.year + 1];
        } else {
            if (components.year == 1) {
                cell.update.text = @"updated a year ago";
            } else {
                cell.update.text = [NSString stringWithFormat:@"updated %d years ago", components.year];
            }
        }
    } else if (components.month > 0) {
        if (components.day > 15) {
            cell.update.text = [NSString stringWithFormat:@"updated %d months ago", components.month + 1];
        } else {
            if (components.month == 1) {
                cell.update.text = @"updated about a month ago";
            } else {
                cell.update.text = [NSString stringWithFormat:@"updated %d months ago", components.month];
            }
        }
    } else if (components.day > 0) {
        if (components.hour > 12) {
            cell.update.text = [NSString stringWithFormat:@"updated %d days ago", components.day + 1];
        } else {
            if (components.day == 1) {
                cell.update.text = @"updated a day ago";
            } else {
                cell.update.text = [NSString stringWithFormat:@"updated %d days ago", components.day];
            }
        }
    } else if (components.hour > 0) {
        if (components.minute > 30) {
            cell.update.text = [NSString stringWithFormat:@"updated about %d hours ago", components.hour + 1];
        } else {
            if (components.hour == 1) {
                cell.update.text = @"updated about an hour ago";
            } else {
                cell.update.text = [NSString stringWithFormat:@"updated about %d hours ago", components.hour];
            }
        }
    } else if (components.minute > 0) {
        if (components.second > 30) {
            cell.update.text = [NSString stringWithFormat:@"updated %d minutes ago", components.minute + 1];
        } else {
            if (components.minute == 1) {
                cell.update.text = @"updated a minute ago";
            } else {
                cell.update.text = [NSString stringWithFormat:@"updated %d minutes ago", components.minute];
            }
        }
    } else {
        cell.update.text = @"updated a few seconds ago";
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (void)fetchIssues
{
    LDSession *session = [LDSession sharedSession];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/api/v3/projects/%@/issues?per_page=100&private_token=%@", session.hostURL, self.projectID, session.privateToken];
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
                       [[LDIssueStore sharedStore] createStore:jsonObject];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self.tableView reloadData];
                       });
                   }];
    
    [dataTask resume];
}

@end
