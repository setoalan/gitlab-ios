//
//  LDMergeRequestViewController.m
//  GitLab
//
//  Created by Alan Seto on 8/13/14.
//  Copyright (c) 2014 Logicdrop. All rights reserved.
//

#import "LDMergeRequestViewController.h"
#import "LDSession.h"

@interface LDMergeRequestViewController ()
{
    int maxWidth;
    int maxHeight;
}

@property (nonatomic) NSURLSession *urlSession;
@property (nonatomic) NSDictionary *jsonObject;
@property (nonatomic) NSArray *commentObject;

@end

@implementation LDMergeRequestViewController

- (instancetype)init:(NSString *)projectID mergeRequestID:(NSString *)mergeRequestID mergeRequestIID:(NSString *)mergeRequestIID title:(NSString *)title
{
    if (self) {
        self.projectID = projectID;
        self.mergeRequestID = mergeRequestID;
        self.navigationItem.title = [NSString stringWithFormat:@"#%@ / %@", mergeRequestIID, title];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addComment)];
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _urlSession = [NSURLSession sessionWithConfiguration:config
                                                    delegate:nil
                                               delegateQueue:nil];
        
        [self fetchMergeRequest];
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
    
    string = [NSString stringWithFormat:@"Merge Request #%@", [[self.jsonObject objectForKey:@"iid"] stringValue]];
    self.mergeRequestNum = [[UILabel alloc] initWithFrame:CGRectMake(20, maxHeight,
        [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}].width,
        [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}].height)];
    self.mergeRequestNum.text = string;
    [self.descView addSubview:self.mergeRequestNum];
    maxHeight += 24;
    
    string = [self.jsonObject objectForKey:@"state"];
    self.state = [[UILabel alloc] initWithFrame:CGRectMake(20, maxHeight, self.view.bounds.size.width,
        [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}].height)];
    if ([[self.jsonObject objectForKey:@"state"] isEqualToString:@"opened"]) {
        self.state.textColor = [UIColor greenColor];
        self.state.text = @"Open";
    } else {
        self.state.textColor = [UIColor redColor];
        if ([[self.jsonObject objectForKey:@"state"] isEqualToString:@"closed"]) {
            self.state.text = @"Closed";
        } else {
            self.state.text = @"√ Merged";
        }
    }
    [self.descView addSubview:self.state];
    maxHeight += 24;
    
    if ([self.jsonObject objectForKey:@"author"] != [NSNull null]) {
        string = [NSString stringWithFormat:@"created by %@", [[self.jsonObject objectForKey:@"author"] objectForKey:@"name"]];
        self.createdBy = [[UILabel alloc] initWithFrame:CGRectMake(20, maxHeight,
            [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].width,
            [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].height)];
        [self.createdBy setFont:[UIFont systemFontOfSize:12]];
        self.createdBy.text = [NSString stringWithFormat:@"created by %@", [[self.jsonObject objectForKey:@"author"] objectForKey:@"name"]];
        [self.descView addSubview:self.createdBy];
        if ([string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].width + 40 > maxWidth)
            maxWidth = [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].width + 40;
        maxHeight += 18;
    }
    
    string = [self.jsonObject objectForKey:@"title"];
    self.mergeRequestTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, maxHeight,
        [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}].width,
        [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}].height)];
    self.mergeRequestTitle.text = string;
    [self.descView addSubview:self.mergeRequestTitle];
    if ([string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}].width + 40 > maxWidth)
        maxWidth = [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}].width + 40;
    maxHeight += 24;
    
    if (![[self.jsonObject objectForKey:@"description"] isEqualToString:@""]) {
        NSArray *descArray = [[self.jsonObject objectForKey:@"description"] componentsSeparatedByString:@"\n"];
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
    
    if ([self.jsonObject objectForKey:@"assignee"] != [NSNull null]) {
        string = [NSString stringWithFormat:@"assigned to %@", [[self.jsonObject objectForKey:@"assignee"] objectForKey:@"name"]];
        self.assignee = [[UILabel alloc] initWithFrame:CGRectMake(20, maxHeight,
            [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].width,
            [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].height)];
        [self.assignee setFont:[UIFont systemFontOfSize:12]];
        self.assignee.text = [NSString stringWithFormat:@"assigned to %@", [[self.jsonObject objectForKey:@"assignee"] objectForKey:@"name"]];
        [self.descView addSubview:self.assignee];
        if ([string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].width + 40 > maxWidth)
            maxWidth = [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].width + 40;
        maxHeight += 18;
    }
    
    maxHeight += 18;
    if ([self.commentObject count] > 0) {
        for (int i=0; i<[self.commentObject count]; i++) {
            UILabel *commentHeaderLabel = [[UILabel alloc] init];
            string = [NSString stringWithFormat:@"%@", [[[self.commentObject objectAtIndex:i] objectForKey:@"author"] objectForKey:@"name"]];
            commentHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, maxHeight,
                [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}].width,
                [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}].height)];
            commentHeaderLabel.text = string;
            [self.descView addSubview:commentHeaderLabel];
            if ([string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}].width + 40 > maxWidth)
                maxWidth = [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}].width + 40;
            maxHeight += 20;
            
            NSArray *commentArray = [[NSString stringWithFormat:@"%@", [[self.commentObject objectAtIndex:i] objectForKey:@"note"]] componentsSeparatedByString:@"\n"];
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

- (void)fetchMergeRequest
{
    LDSession *session = [LDSession sharedSession];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/api/v3/projects/%@/merge_request/%@?private_token=%@", session.hostURL, self.projectID, self.mergeRequestID, session.privateToken];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:20.0];
    
    NSURLSessionDataTask *dataTask =
    [_urlSession dataTaskWithRequest:request
                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                       _jsonObject = [NSJSONSerialization JSONObjectWithData:data
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
    NSString *urlString = [NSString stringWithFormat:@"http://%@/api/v3/projects/%@/merge_request/%@/comments?private_token=%@", session.hostURL, self.projectID, self.mergeRequestID, session.privateToken];
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
