//
//  LDCommitsViewController.m
//  GitLab
//
//  Created by Alan Seto on 7/18/14.
//  Copyright (c) 2014 Logicdrop. All rights reserved.
//

#import "LDCommitsViewController.h"
#import "LDCommitsCell.h"
#import "LDSession.h"
#import "LDCommitsStore.h"
#import "LDCommitViewController.h"

@interface LDCommitsViewController ()

@property (nonatomic) NSURLSession *urlSession;

@end

@implementation LDCommitsViewController

- (instancetype)init:(NSString *)projectName projectIdentification:(NSString *)projectID branch:(NSString *)branch
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.projectID = projectID;
        self.projectName = projectName;
        self.branch = branch;
        self.tabBarItem.title = @"Commits";
        self.tabBarItem.image = [UIImage imageNamed:@"commits"];
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _urlSession = [NSURLSession sessionWithConfiguration:config
                                                    delegate:nil
                                               delegateQueue:nil];
        
        [self fetchCommits];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tabBarController.navigationItem.title = self.projectName;
    
    UINib *nib = [UINib nibWithNibName:@"LDCommitsCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"LDCommitsCell"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LDCommitViewController *commitViewController = [[LDCommitViewController alloc] init:self.projectID commitTitle:[[[LDCommitsStore sharedStore] getItem:indexPath] objectForKey:@"title"] commitHash:[[[LDCommitsStore sharedStore] getItem:indexPath] objectForKey:@"short_id"]];
    
    [self.navigationController pushViewController:commitViewController animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[LDCommitsStore sharedStore] allItems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"LDCommitsCell";
    
    LDCommitsCell *cell = (LDCommitsCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LDCommistCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.shortID.text = [[[LDCommitsStore sharedStore] getItem:indexPath] objectForKey:@"short_id"];
    cell.title.font = [UIFont boldSystemFontOfSize:12];
    cell.title.text = [[[LDCommitsStore sharedStore] getItem:indexPath] objectForKey:@"title"];
    cell.author.text = [[[LDCommitsStore sharedStore] getItem:indexPath] objectForKey:@"author_name"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.000Z"];
    NSDate *date = [dateFormatter dateFromString:[[[LDCommitsStore sharedStore] getItem:indexPath] objectForKey:@"created_at"]];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit) fromDate:date toDate:[NSDate date] options:0] ;
    if (components.year > 0) {
        if (components.month > 6) {
            cell.date.text = [NSString stringWithFormat:@"%d years ago", components.year + 1];
        } else {
            if (components.year == 1) {
                cell.date.text = @"a year ago";
            } else {
                cell.date.text = [NSString stringWithFormat:@"%d years ago", components.year];
            }
        }
    } else if (components.month > 0) {
        if (components.day > 15) {
            cell.date.text = [NSString stringWithFormat:@"%d months ago", components.month + 1];
        } else {
            if (components.month == 1) {
                cell.date.text = @"about a month ago";
            } else {
                cell.date.text = [NSString stringWithFormat:@"%d months ago", components.month];
            }
        }
    } else if (components.day > 0) {
        if (components.hour > 12) {
            cell.date.text = [NSString stringWithFormat:@"%d days ago", components.day + 1];
        } else {
            if (components.day == 1) {
                cell.date.text = @"a day ago";
            } else {
                cell.date.text = [NSString stringWithFormat:@"%d days ago", components.day];
            }
        }
    } else if (components.hour > 0) {
        if (components.minute > 30) {
            cell.date.text = [NSString stringWithFormat:@"about %d hours ago", components.hour + 1];
        } else {
            if (components.hour == 1) {
                cell.date.text = @"about an hour ago";
            } else {
                cell.date.text = [NSString stringWithFormat:@"about %d hours ago", components.hour];
            }
        }
    } else if (components.minute > 0) {
        if (components.second > 30) {
            cell.date.text = [NSString stringWithFormat:@"%d minutes ago", components.minute + 1];
        } else {
            if (components.minute == 1) {
                cell.date.text = @"a minute ago";
            } else {
                cell.date.text = [NSString stringWithFormat:@"%d minutes ago", components.minute];
            }
        }
    } else {
        cell.date.text = @"a few seconds ago";
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 61;
}

- (void)fetchCommits
{
    LDSession *session = [LDSession sharedSession];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/api/v3/projects/%@/repository/commits?ref_name=%@&per_page=50&private_token=%@", session.hostURL, self.projectID, self.branch, session.privateToken];
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
                       [[LDCommitsStore sharedStore] createStore:jsonObject];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self.tableView reloadData];
                       });
                   }];
    
    [dataTask resume];
}

@end
