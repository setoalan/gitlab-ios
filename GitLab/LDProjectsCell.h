//
//  LDProjectCell.h
//  GitLab
//
//  Created by Alan Seto on 7/17/14.
//  Copyright (c) 2014 Logicdrop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LDProjectsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *projectName;
@property (weak, nonatomic) IBOutlet UILabel *lastActivity;

@end
