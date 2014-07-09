//
//  RYViewController.m
//  Platform
//
//  Created by JanneH on 04/07/2014.
//  Copyright (c) 2014 raceyourself. All rights reserved.
//

#import "RYViewController.h"
#import "Models/AccessToken.h"
#import "Models/User.h"
#import "Models/Friend.h"
#import "Models/Challenge.h"
#import "Models/Notification.h"
#import "API.h"

@interface RYViewController ()

@end

@implementation RYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	  // Do any additional  Models
    // etup after loading the view, typically from a nib.
    
    self.debugTextView = [[UITextView alloc] initWithFrame:
      CGRectMake(10, 50, 300, 200)];
    [self.debugTextView setText:@"Syncing.."];
    // debugTextView.delegate = self;
    [self.view addSubview:self.debugTextView];
   
    AccessToken *token = [AccessToken MR_findFirst];
    if (token == nil || nil == nil) {
      [API loginWithUsername:@"janne.husberg@raceyourself.com" withPassword:@"testing123" withCallback:^BOOL (NSString *state) {
        if ([state isEqualToString:@"success"]) {
          [API syncWithCallback:^BOOL (NSString *state) {
            if ([state isEqualToString:@"full"] || [state isEqualToString:@"partial"]) {
              NSLog(@"Synced to server");
              AccessToken *token = [AccessToken MR_findFirst];
              [self.debugTextView setText:[NSString stringWithFormat:@"Hello %@, you have %d authentications, %d friends (%d users), %d challenges and %d notifications", token.user.name, token.user.authentications.count, [Friend MR_findAll].count, [User MR_findAll].count, [Challenge MR_findAll].count, [Notification MR_findAll].count]];
            } else {
              NSLog(@"Could not sync!");
              [self.debugTextView setText:@"Could not sync!"];
            }
            return YES;
          }];
        } else {
          NSLog(@"Could not log in!");
          [self.debugTextView setText:@"Could not log in!"];
        }
        return YES;
      }]; 
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
