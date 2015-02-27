//
//  LDMergeRequestsViewController.h
//  GitLab
//
//  Created by Alan Seto on 7/18/14.
//  Copyright (c) 2014 Logicdrop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LDMergeRequestsViewController : UITableViewController

@property (nonatomic, weak) NSString *projectName;
@property (nonatomic, weak) NSString *projectID;

- (instancetype)init:(NSString *)projectID;

@end
