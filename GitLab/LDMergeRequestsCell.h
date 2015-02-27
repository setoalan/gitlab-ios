//
//  LDMergeRequestCell.h
//  GitLab
//
//  Created by Alan Seto on 7/18/14.
//  Copyright (c) 2014 Logicdrop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LDMergeRequestsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *mergeRequestID;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *state;
@property (weak, nonatomic) IBOutlet UILabel *author;
@property (weak, nonatomic) IBOutlet UILabel *update;

@end
