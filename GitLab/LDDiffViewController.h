//
//  LDDiffViewController.h
//  GitLab
//
//  Created by Alan Seto on 8/11/14.
//  Copyright (c) 2014 Logicdrop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LDDiffViewController : UIViewController <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *diffView;

- (instancetype)init:(NSIndexPath *)indexPath;

@end
