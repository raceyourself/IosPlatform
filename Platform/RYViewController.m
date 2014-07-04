//
//  RYViewController.m
//  Platform
//
//  Created by JanneH on 04/07/2014.
//  Copyright (c) 2014 raceyourself. All rights reserved.
//

#import "RYViewController.h"
#import "Models/AccessToken.h"

@interface RYViewController ()

@end

@implementation RYViewController

NSMutableData   *buffer;
NSURLConnection *connection;

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
      [self debugLog:@"\nNo access token"];

      NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"password", @"grant_type", 
                                @"c9842247411621e35dbaf21ad0e15c263364778bf9a46b5e93f64ff2b6e0e17c", @"client_id",
                                @"75f3e999c01942219bea1e9c0a1f76fd24c3d55df6b1c351106cc686f7fcd819", @"client_secret",
                                @"janne.husberg@raceyourself.com", @"username",
                                @"testing123", @"password",
                                nil];
      NSData *postData = [self encodeDictionary:postDict];

      NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://a.staging.raceyourself.com/oauth/token"]];
      NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
      [request setHTTPMethod:@"POST"];
      [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
      [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
      [request setHTTPBody:postData];
      connection = [NSURLConnection connectionWithRequest:request delegate:self];
      if (connection) {
        buffer = [NSMutableData data];
        [connection start];
      } else {
        [self debugLog:@"\nCould not connection to server"];
      }

    } else {
      [self debugLog:@"\nAccess token:\n"];
      [self debugLog:token.access_token];
    }
   
    [self debugLog:@"\nDidn't crash"];
}

- (NSData*)encodeDictionary:(NSDictionary*)dictionary 
{
    NSMutableArray *parts = [[NSMutableArray alloc] init];
    for (NSString *key in dictionary) {
      NSString *encodedValue = [[dictionary objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
      NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; 
      NSString *part = [NSString stringWithFormat: @"%@=%@", encodedKey, encodedValue];
      [parts addObject:part];
    }
    NSString *encodedDictionary = [parts componentsJoinedByString:@"&"];
    return [encodedDictionary dataUsingEncoding:NSUTF8StringEncoding];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    connection = nil;
    buffer = nil;
      
    [self debugLog:@"\nConnection failed"];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self debugLog:@"\nResponse"];
    [buffer setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self debugLog:@"\nData"];
    [buffer appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self debugLog:@"\nLoaded"];
  
    NSError *error = nil;
    id response = [NSJSONSerialization JSONObjectWithData:buffer options:0 error:&error];
    connection = nil;
    buffer = nil;

    AccessToken *token = [AccessToken MR_createEntity];
    token.access_token = [response objectForKey:@"access_token"];
    token.expiration_time = [NSDate date];

    [[NSManagedObjectContext MR_defaultContext] 
    MR_saveToPersistentStoreAndWait];
    
    [self debugLog:@"\nLogged in"];
    [self debugLog:token.access_token];
}

- (void)debugLog:(NSString *)string
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
      NSString *buffer = [self.debugTextView.text stringByAppendingString:string];
      self.debugTextView.text = buffer;
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
