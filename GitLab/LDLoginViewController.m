//
//  LDLoginViewController.m
//  GitLab
//
//  Created by Alan Seto on 7/16/14.
//  Copyright (c) 2014 Logicdrop. All rights reserved.
//

#import "LDLoginViewController.h"
#import "LDSession.h"
#import "LDProjectsViewController.h"

@interface LDLoginViewController ()

@property (nonatomic) NSURLSession *urlSession;

@end

@implementation LDLoginViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _urlSession = [NSURLSession sessionWithConfiguration:config
                                                 delegate:nil
                                            delegateQueue:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.password.delegate = self;
}

- (IBAction)signIn:(id)sender
{
    [self resignFirstResponder];
    [self fetchPrivateToken];
}

- (void)fetchPrivateToken
{
    NSString *post = [NSString stringWithFormat: @"login=%@&password=%@", self.username.text, self.password.text];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    NSString *urlString = [NSString stringWithFormat:@"http://%@/api/v3/session", self.hostURL.text];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:20.0];
    [request setHTTPBody:postData];
    
    NSURLSessionDataTask *dataTask =
    [_urlSession dataTaskWithRequest:request
                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                        NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                                                   options:0
                                                                                     error:nil];
                        LDSession *session = [LDSession sharedSession];
                        session.hostURL = self.hostURL.text;
                        session.privateToken = jsonObject[@"private_token"];
                        
                        session.privateToken = @"UyHvxc7yhn3G5vsnbg3Q";
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            LDProjectsViewController *projectsViewController = [[LDProjectsViewController alloc] init];
                            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:projectsViewController];
                            navigationController.navigationBar.translucent = NO;
                            
                            [self presentViewController:navigationController animated:YES completion:nil];
                        });
                    }];

    [dataTask resume];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self fetchPrivateToken];
    return YES;
}

@end
