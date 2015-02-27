//
//  LDSession.m
//  GitLab
//
//  Created by Alan Seto on 7/16/14.
//  Copyright (c) 2014 Logicdrop. All rights reserved.
//

#import "LDSession.h"

@implementation LDSession

+ (instancetype)sharedSession
{
    static LDSession *sharedSession = nil;
    
    if (!sharedSession) {
        sharedSession = [[self alloc] init];
    }
    return sharedSession;
}

@end
