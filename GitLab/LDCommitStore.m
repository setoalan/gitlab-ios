//
//  LDCommitStore.m
//  GitLab
//
//  Created by Alan Seto on 8/11/14.
//  Copyright (c) 2014 Logicdrop. All rights reserved.
//

#import "LDCommitStore.h"

@interface LDCommitStore ()

@property (nonatomic) NSArray *privateItems;

@end

@implementation LDCommitStore

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use + [LDCommitStore sharedStore]" userInfo:nil];
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
    static LDCommitStore *sharedStore = nil;
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
