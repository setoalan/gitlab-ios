//
//  LDCommitsViewController.h
//  GitLab
//
//  Created by Alan Seto on 7/18/14.
//  Copyright (c) 2014 Logicdrop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LDCommitsViewController : UITableViewController

@property (nonatomic, weak) NSString *projectName;
@property (nonatomic, weak) NSString *projectID;
@property (nonatomic, weak) NSString *branch;

- (instancetype)init:(NSString *)projectName projectIdentification:(NSString *)projectID branch:(NSString *)branch;

@end
