//
//  LDIssueStore.m
//  GitLab
//
//  Created by Alan Seto on 7/21/14.
//  Copyright (c) 2014 Logicdrop. All rights reserved.
//

#import "LDIssueStore.h"

@interface LDIssueStore ()

@property (nonatomic) NSArray *privateItems;

@end

@implementation LDIssueStore

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use + [LDIssueStore sharedStore]" userInfo:nil];
    return nil;
}

- (instancetype)initPrivate
{
    self = [super init];
    if (self) {
        _privateItems = [[NSArray alloc] init];
    }
    return self;
}

- (NSArray *)allItems
{
    return self.privateItems;
}

- (void)createStore:(NSArray *)jsonObject
{
    self.privateItems = jsonObject;
}

+ (instancetype)sharedStore
{
    static LDIssueStore *sharedStore = nil;
    if (!sharedStore) {
        sharedStore = [[self alloc] initPrivate];
    }
    return sharedStore;
}

- (NSDictionary *)getItem:(NSIndexPath *)index
{
    return [self.privateItems objectAtIndex:index.row];
}

@end
