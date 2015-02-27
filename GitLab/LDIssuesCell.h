//
//  LDIssueCell.h
//  GitLab
//
//  Created by Alan Seto on 7/18/14.
//  Copyright (c) 2014 Logicdrop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LDIssuesCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *issueID;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *state;
@property (weak, nonatomic) IBOutlet UILabel *assignee;
@property (weak, nonatomic) IBOutlet UILabel *update;

@end
