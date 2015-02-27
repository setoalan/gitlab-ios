//
//  LDProjectsViewController.h
//  GitLab
//
//  Created by Alan Seto on 7/16/14.
//  Copyright (c) 2014 Logicdrop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LDProjectsViewController : UITableViewController <NSURLConnectionDelegate, UIAlertViewDelegate>

@property (nonatomic, copy) NSArray *projects;
@property (nonatomic, copy) NSArray *branches;

- (void)fetchProjectBranches;

@end
