//
//  LDSession.h
//  GitLab
//
//  Created by Alan Seto on 7/16/14.
//  Copyright (c) 2014 Logicdrop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LDSession : NSObject

@property (nonatomic) NSString *hostURL;
@property (nonatomic) NSString *privateToken;

+ (instancetype)sharedSession;

@end
