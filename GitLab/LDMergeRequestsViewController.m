//
//  LDMergeRequestsViewController.m
//  GitLab
//
//  Created by Alan Seto on 7/18/14.
//  Copyright (c) 2014 Logicdrop. All rights reserved.
//

#import "LDMergeRequestsViewController.h"
#import "LDMergeRequestsCell.h"
#import "LDSession.h"
#import "LDMergeRequestStore.h"
#import "LDMergeRequestViewController.h"

@interface LDMergeRequestsViewController ()

@property (nonatomic) NSURLSession *urlSession;

@end

@implementation LDMergeRequestsViewController

- (instancetype)init:(NSString *)projectID
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.projectID = projectID;
        self.tabBarItem.title = @"Merge Requests";
        self.tabBarItem.image = [UIImage imageNamed:@"merge_requests"];
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _urlSession = [NSURLSession sessionWithConfiguration:config
                                                    delegate:nil
                                               delegateQueue:nil];
        
        [self fetchMergeRequests];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:@"LDMergeRequestsCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"LDMergeRequestsCell"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LDMergeRequestViewController *mergeRequestViewController = [[LDMergeRequestViewController alloc] init:self.projectID mergeRequestID:[[[LDMergeRequestStore sharedStore] getItem:indexPath] objectForKey:@"id"] mergeRequestIID:[[[LDMergeRequestStore sharedStore] getItem:indexPath] objectForKey:@"iid"] title:[[[LDMergeRequestStore sharedStore] getItem:indexPath] objectForKey:@"title"]];
    
    [self.navigationController pushViewController:mergeRequestViewController animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[LDMergeRequestStore sharedStore] allItems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"LDMergeRequestsCell";
    
    LDMergeRequestsCell *cell = (LDMergeRequestsCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.mergeRequestID.text = [NSString stringWithFormat:@"#%@",[[[LDMergeRequestStore sharedStore] getItem:indexPath] objectForKey:@"iid"]];
    cell.title.font = [UIFont boldSystemFontOfSize:12];
    cell.title.text = [[[LDMergeRequestStore sharedStore] getItem:indexPath] objectForKey:@"title"];
    cell.state.text = [[[LDMergeRequestStore sharedStore] getItem:indexPath] objectForKey:@"state"];
    if ([[[[LDMergeRequestStore sharedStore] getItem:indexPath] objectForKey:@"state"] isEqualToString:@"opened"]) {
        cell.state.textColor = [UIColor greenColor];
        cell.state.text = @"Open";
    } else {
        cell.state.textColor = [UIColor redColor];
        if ([[[[LDMergeRequestStore sharedStore] getItem:indexPath] objectForKey:@"state"] isEqualToString:@"closed"]) {
            cell.state.text = @"Closed";
        } else {
            cell.state.text = @"√ Merged";
        }
    }
    cell.author.text = [NSString stringWithFormat:@"authored by %@", [[[[LDMergeRequestStore sharedStore] getItem:indexPath] objectForKey:@"author"] objectForKey:@"name"]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.000Z"];
    NSDate *date = [dateFormatter dateFromString:[[[LDMergeRequestStore sharedStore] getItem:indexPath] objectForKey:@"updated_at"]];
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

- (void)fetchMergeRequests
{
    LDSession *session = [LDSession sharedSession];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/api/v3/projects/%@/merge_requests?state=all&per_page=100&private_token=%@", session.hostURL, self.projectID, session.privateToken];
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
                       
                       [[LDMergeRequestStore sharedStore] createStore:[[jsonObject reverseObjectEnumerator] allObjects]];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self.tableView reloadData];
                       });
                   }];
    
    [dataTask resume];
}

@end
