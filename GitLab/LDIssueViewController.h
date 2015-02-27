//
//  LDIssueViewController.h
//  GitLab
//
//  Created by Alan Seto on 8/11/14.
//  Copyright (c) 2014 Logicdrop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LDIssueViewController : UIViewController <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *descView;

@property (nonatomic, weak) NSString *projectID;
@property (nonatomic, weak) NSString *issueID;

@property (strong, nonatomic) UILabel *issueNum;
@property (strong, nonatomic) UILabel *state;
@property (strong, nonatomic) UILabel *createdBy;
@property (strong, nonatomic) UILabel *issueTitle;
@property (strong, nonatomic) UILabel *description;
@property (strong, nonatomic) UILabel *milestone;
@property (strong, nonatomic) UILabel *labels;
@property (strong, nonatomic) UILabel *assignee;

- (instancetype)init:(NSString *)projectID issueID:(NSString *)issueID issueIID:(NSString *)issueIID title:(NSString *)title;
- (void)addComment;

@end
