//
//  LDLoginViewController.h
//  GitLab
//
//  Created by Alan Seto on 7/16/14.
//  Copyright (c) 2014 Logicdrop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LDLoginViewController : UIViewController <NSURLConnectionDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *hostURL;
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *signIn;

@end
