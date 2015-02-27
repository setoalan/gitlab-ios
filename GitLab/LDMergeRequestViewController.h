//
//  LDMergeRequestViewController.h
//  GitLab
//
//  Created by Alan Seto on 8/13/14.
//  Copyright (c) 2014 Logicdrop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LDMergeRequestViewController : UIViewController <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *descView;

@property (nonatomic, weak) NSString *projectID;
@property (nonatomic, weak) NSString *mergeRequestID;

@property (strong, nonatomic) UILabel *mergeRequestNum;
@property (strong, nonatomic) UILabel *state;
@property (strong, nonatomic) UILabel *createdBy;
@property (strong, nonatomic) UILabel *mergeRequestTitle;
@property (strong, nonatomic) UILabel *description;
@property (strong, nonatomic) UILabel *assignee;

- (instancetype)init:(NSString *)projectID mergeRequestID:(NSString *)mergeRequestID mergeRequestIID:(NSString *)mergeRequestIID title:(NSString *)title;
- (void)addComment;

@end
