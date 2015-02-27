//
//  LDIssueStore.h
//  GitLab
//
//  Created by Alan Seto on 7/21/14.
//  Copyright (c) 2014 Logicdrop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LDIssueStore : NSObject

@property (nonatomic, readonly) NSArray *allItems;

+ (instancetype)sharedStore;
- (id)getItem:(NSIndexPath *)index;
- (void)createStore:(NSArray *)jsonObject;

@end
