//
//  LDCommitViewController.h
//  GitLab
//
//  Created by Alan Seto on 8/11/14.
//  Copyright (c) 2014 Logicdrop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LDCommitViewController : UITableViewController

@property (nonatomic, weak) NSString *projectID;
@property (nonatomic, weak) NSString *hash;

- (instancetype)init:(NSString *)projectID commitTitle:(NSString *)title commitHash:(NSString *)hash;

@end
