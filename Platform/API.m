//
//  API.m
//  Platform
//
//  Created by Janne Husberg on 07/07/2014.
//  Copyright (c) 2014 raceyourself. All rights reserved.
//

#import "API.h"
#import "AFNetworking.h"
#import "Models/AccessToken.h"

@implementation API

static NSString *const RYWebserviceUrl = @"http://a.staging.raceyourself.com/";
static NSString *const RYApiUrl = @"http://a.staging.raceyourself.com/api/1/";
static NSString *const RYClientId = @"c9842247411621e35dbaf21ad0e15c263364778bf9a46b5e93f64ff2b6e0e17c";
static NSString *const RYClientSecret = @"75f3e999c01942219bea1e9c0a1f76fd24c3d55df6b1c351106cc686f7fcd819";

static NSMutableArray *loginCallbacks = nil;

+ (void)addLoginCallback:(BOOL(^)(NSString *state))callback
{
  if (loginCallbacks == nil) loginCallbacks = [NSMutableArray new];
  [loginCallbacks addObject:callback];
}

+ (void)onLogin:(NSString *)state
{
  NSMutableArray *completedCallbacks = [NSMutableArray new];
  for (BOOL(^callback)(NSString *state) in loginCallbacks) {
    if (callback(state) == YES) {
      [completedCallbacks addObject:callback];
    }
  }
  [loginCallbacks removeObjectsInArray:completedCallbacks];
}

+ (void)loginWithUsername:(NSString *)username withPassword:(NSString *)password 
                                               withCallback:(BOOL(^)(NSString *state))callback
{
  [API addLoginCallback:callback];
  [API loginWithUsername:username withPassword:password];
}

+ (void)loginWithUsername:(NSString *)username withPassword:(NSString *)password 
{
  NSLog(@"API:loginWithUsername(%@)", username);

  NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"password", @"grant_type", 
                            RYClientId, @"client_id",
                            RYClientSecret, @"client_secret",
                            username, @"username",
                            password, @"password",
                            nil];
  NSData *postData = [self encodeDictionary:postDict];

  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[RYWebserviceUrl stringByAppendingString:@"oauth/token"]]];
  NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
  [request setHTTPMethod:@"POST"];
  [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
  [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
  [request setHTTPBody:postData];

  AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  operation.responseSerializer = [AFJSONResponseSerializer serializer];

  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
    AccessToken *token = [AccessToken MR_createEntity];
    token.access_token = [JSON objectForKey:@"access_token"];
    int expires_in = [[JSON objectForKey:@"expires_in"] intValue];
    token.expiration_time = [[NSDate date] dateByAddingTimeInterval:expires_in];

    [[NSManagedObjectContext MR_defaultContext]
    MR_saveToPersistentStoreAndWait]; 
    NSLog(@"API:loginWithUsername(%@) succeeded", username);
    [API onLogin:@"success"];
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"API:loginWithUsername(%@) failed with %@", username, [error localizedDescription]);
    [API onLogin:@"failure"];
  }];

  [operation start];
}

+ (NSData*)encodeDictionary:(NSDictionary*)dictionary 
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

@end
