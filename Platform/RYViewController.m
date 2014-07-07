//
//  RYViewController.m
//  Platform
//
//  Created by JanneH on 04/07/2014.
//  Copyright (c) 2014 raceyourself. All rights reserved.
//

#import "RYViewController.h"
#import "Models/AccessToken.h"
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
    [self.debugTextView setText:@"View loaded"];
    // debugTextView.delegate = self;
    [self.view addSubview:self.debugTextView];
   
    AccessToken *token = [AccessToken MR_findFirst];
    if (token == nil || nil == nil) {
      [API loginWithUsername:@"janne.husberg@raceyourself.com" withPassword:@"testing123" withCallback:^BOOL (NSString *state) {
        NSLog(@"Bob's your uncle! %@", state);
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
