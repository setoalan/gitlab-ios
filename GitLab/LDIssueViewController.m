//
//  LDIssueViewController.m
//  GitLab
//
//  Created by Alan Seto on 8/11/14.
//  Copyright (c) 2014 Logicdrop. All rights reserved.
//

#import "LDIssueViewController.h"
#import "LDSession.h"

@interface LDIssueViewController ()
{
    int maxWidth;
    int maxHeight;
}

@property (nonatomic) NSURLSession *urlSession;
@property (nonatomic) NSDictionary *issueObject;
@property (nonatomic) NSArray *commentObject;

@end

@implementation LDIssueViewController

- (instancetype)init:(NSString *)projectID issueID:(NSString *)issueID issueIID:(NSString *)issueIID title:(NSString *)title
{
    self = [super initWithNibName:@"LDIssueViewController" bundle:nil];
    if (self) {
        self.projectID = projectID;
        self.issueID = issueID;
        self.navigationItem.title = [NSString stringWithFormat:@"#%@ / %@", issueIID, title];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addComment)];
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _urlSession = [NSURLSession sessionWithConfiguration:config
                                                    delegate:nil
                                               delegateQueue:nil];
        
        [self fetchIssue];
    }
    return self;
}

- (void)addComment
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Add Comment"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UITextField * alertTextField = [alertView textFieldAtIndex:0];
    NSLog(@"alerttextfiled - %@", alertTextField.text);
    
    // POST to server
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.descView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollV withView:(UIView *)view atScale:(float)scale
{
    [self.scrollView setContentSize:CGSizeMake(scale * maxWidth, scale * maxHeight + 80)];
}

- (void)reloadData
{
    CGRect screenRect = self.view.bounds;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:screenRect];
    self.scrollView.minimumZoomScale = 0.5;
    self.scrollView.maximumZoomScale = 3.0;
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    
    self.descView = [[UIView alloc] initWithFrame:screenRect];
    [self.scrollView addSubview:self.descView];
    NSString *string;
    maxWidth = self.view.bounds.size.width;
    maxHeight = 20;
    
    string = [NSString stringWithFormat:@"Issue #%@", [[self.issueObject objectForKey:@"iid"] stringValue]];
    self.issueNum = [[UILabel alloc] initWithFrame:CGRectMake(20, maxHeight,
        [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}].width,
        [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}].height)];
    self.issueNum.text = string;
    [self.descView addSubview:self.issueNum];
    maxHeight += 24;
    
    string = [self.issueObject objectForKey:@"state"];
    self.state = [[UILabel alloc] initWithFrame:CGRectMake(20, maxHeight, self.view.bounds.size.width,
        [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}].height)];
    if ([[self.issueObject objectForKey:@"state"] isEqualToString:@"opened"] ||
        [[self.issueObject objectForKey:@"state"] isEqualToString:@"reopened"]) {
        self.state.textColor = [UIColor colorWithRed:0 green:200.0f/255.0f blue:0 alpha:1];
        self.state.text = @"Open";
    } else {
        self.state.textColor = [UIColor redColor];
        self.state.text = @"Closed";
    }
    [self.descView addSubview:self.state];
    maxHeight += 24;
    
    if ([self.issueObject objectForKey:@"author"] != [NSNull null]) {
        string = [NSString stringWithFormat:@"created by %@", [[self.issueObject objectForKey:@"author"] objectForKey:@"name"]];
        self.createdBy = [[UILabel alloc] initWithFrame:CGRectMake(20, maxHeight,
            [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].width,
            [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].height)];
        [self.createdBy setFont:[UIFont systemFontOfSize:12]];
        self.createdBy.text = [NSString stringWithFormat:@"created by %@", [[self.issueObject objectForKey:@"author"] objectForKey:@"name"]];
        [self.descView addSubview:self.createdBy];
        if ([string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].width + 40 > maxWidth)
            maxWidth = [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].width + 40;
        maxHeight += 18;
    }
    
    string = [self.issueObject objectForKey:@"title"];
    self.issueTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, maxHeight,
        [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}].width,
        [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}].height)];
    self.issueTitle.text = string;
    [self.descView addSubview:self.issueTitle];
    if ([string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}].width + 40 > maxWidth)
        maxWidth = [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}].width + 40;
    maxHeight += 24;
    if (![[self.issueObject objectForKey:@"description"] isEqualToString:@""]) {
        NSArray *descArray = [[self.issueObject objectForKey:@"description"] componentsSeparatedByString:@"\n"];
        for (NSString *desc in descArray) {
            self.description = [[UILabel alloc] initWithFrame:CGRectMake(40, maxHeight,
                [desc sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].width,
                [desc sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].height)];
            [self.description setFont:[UIFont systemFontOfSize:12]];
            self.description.text = desc;
            [self.descView addSubview:self.description];
            if ([desc sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].width + 60 > maxWidth)
                maxWidth = [desc sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].width + 60;
            maxHeight += [desc sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].height;
        }
        maxHeight += 8;
    }

    if ([self.issueObject objectForKey:@"milestone"] != [NSNull null]) {
        string = [[self.issueObject objectForKey:@"milestone"] objectForKey:@"title"];
        self.milestone = [[UILabel alloc] initWithFrame:CGRectMake(20, maxHeight,
           [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}].width,
           [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}].height)];
        self.milestone.text = string;
        [self.descView addSubview:self.milestone];
        maxHeight += 24;
    }
    
    if ([self.issueObject objectForKey:@"labels"] != [NSNull null]) {
        string = @"";
        for (NSString *labelString in [self.issueObject objectForKey:@"labels"])
            string = [string stringByAppendingString:[NSString stringWithFormat:@"<%@>, ", labelString]];
        string = [string substringToIndex:[string length] - 2];
        self.labels = [[UILabel alloc] initWithFrame:CGRectMake(20, maxHeight,
            [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}].width,
            [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}].height)];
        self.labels.textColor = [UIColor colorWithRed:51.0f/255.0f green:181.0/255.0f blue:229.0f/255.0f alpha:1];
        self.labels.text = string;
        [self.descView addSubview:self.labels];
        if ([string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}].width + 40 > maxWidth)
            maxWidth = [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}].width + 40;
        maxHeight += 24;
    }
    
    if ([self.issueObject objectForKey:@"assignee"] != [NSNull null]) {
        string = [NSString stringWithFormat:@"assigned to %@", [[self.issueObject objectForKey:@"assignee"] objectForKey:@"name"]];
        self.assignee = [[UILabel alloc] initWithFrame:CGRectMake(20, maxHeight,
        [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].width,
        [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].height)];
        [self.assignee setFont:[UIFont systemFontOfSize:12]];
        self.assignee.text = string;
        [self.descView addSubview:self.assignee];
        if ([string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].width + 40 > maxWidth)
            maxWidth = [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].width + 40;
         maxHeight += 18;
    }
    
    maxHeight += 18;
    if ([self.commentObject count] > 0) {
        for (int i=0; i<[self.commentObject count]; i++) {
            UILabel *commentHeaderLabel = [[UILabel alloc] init];
            string = [NSString stringWithFormat:@"%@ • %@", [[[self.commentObject objectAtIndex:i] objectForKey:@"author"] objectForKey:@"name"], [self getDate:(NSString *)[[self.commentObject objectAtIndex:i] objectForKey:@"created_at"]]];
            commentHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, maxHeight,
                [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}].width,
                [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}].height)];
            commentHeaderLabel.text = string;
            [self.descView addSubview:commentHeaderLabel];
            if ([string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}].width + 40 > maxWidth)
                maxWidth = [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}].width + 40;
            maxHeight += 20;
            
            NSArray *commentArray = [[NSString stringWithFormat:@"%@", [[self.commentObject objectAtIndex:i] objectForKey:@"body"]] componentsSeparatedByString:@"\n"];
            for (NSString *comment in commentArray) {
                UILabel *commentBodyLabel = [[UILabel alloc] init];
                commentBodyLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, maxHeight,
                    [comment sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].width + 30,
                    [comment sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].height + 30)];
                [commentBodyLabel setFont:[UIFont systemFontOfSize:12]];
                commentBodyLabel.text = comment;
                [self.descView addSubview:commentBodyLabel];
                if ([comment sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].width + 40 > maxWidth)
                    maxWidth = [comment sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].width + 40;
                maxHeight += 12;
            }
            maxHeight += 30;
        }
    }
    
    CGRect bigRect;
    bigRect.size.width = maxWidth;
    bigRect.size.height = maxHeight + 80;
    self.scrollView.contentSize = bigRect.size;
}

- (NSString *)getDate:dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.000Z"];
    NSDate *date = [dateFormatter dateFromString:dateString];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit) fromDate:date toDate:[NSDate date] options:0] ;
    if (components.year > 0) {
        if (components.month > 6) {
            return [NSString stringWithFormat:@"%d years ago", components.year + 1];
        } else {
            if (components.year == 1) {
                return @"a year ago";
            } else {
                return [NSString stringWithFormat:@"%d years ago", components.year];
            }
        }
    } else if (components.month > 0) {
        if (components.day > 15) {
            return [NSString stringWithFormat:@"%d months ago", components.month + 1];
        } else {
            if (components.month == 1) {
                return @"about a month ago";
            } else {
                return [NSString stringWithFormat:@"%d months ago", components.month];
            }
        }
    } else if (components.day > 0) {
        if (components.hour > 12) {
            return [NSString stringWithFormat:@"%d days ago", components.day + 1];
        } else {
            if (components.day == 1) {
                return @"a day ago";
            } else {
                return [NSString stringWithFormat:@"%d days ago", components.day];
            }
        }
    } else if (components.hour > 0) {
        if (components.minute > 30) {
            return [NSString stringWithFormat:@"about %d hours ago", components.hour + 1];
        } else {
            if (components.hour == 1) {
                return @"about an hour ago";
            } else {
                return [NSString stringWithFormat:@"about %d hours ago", components.hour];
            }
        }
    } else if (components.minute > 0) {
        if (components.second > 30) {
            return [NSString stringWithFormat:@"%d minutes ago", components.minute + 1];
        } else {
            if (components.minute == 1) {
                return @"a minute ago";
            } else {
                return [NSString stringWithFormat:@"%d minutes ago", components.minute];
            }
        }
    } else {
        return @"a few seconds ago";
    }
}

- (void)fetchIssue
{
    LDSession *session = [LDSession sharedSession];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/api/v3/projects/%@/issues/%@?private_token=%@", session.hostURL, self.projectID, self.issueID, session.privateToken];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:20.0];
    
    NSURLSessionDataTask *dataTask =
    [_urlSession dataTaskWithRequest:request
                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                       _issueObject = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:0
                                                                       error:nil];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self fetchComments];
                       });
                   }];
    
    [dataTask resume];
}

- (void)fetchComments
{
    LDSession *session = [LDSession sharedSession];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/api/v3/projects/%@/issues/%@/notes?private_token=%@", session.hostURL, self.projectID, self.issueID, session.privateToken];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:20.0];
    
    NSURLSessionDataTask *dataTask =
    [_urlSession dataTaskWithRequest:request
                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                       _commentObject = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:0
                                                                       error:nil];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self reloadData];
                       });
                   }];
    
    [dataTask resume];
}

@end
