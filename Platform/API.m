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
#import "Models/User+Mapping.h"
#import "Models/Authentication.h"
#import "Models/Challenge.h"
#import "Models/Friendship+Mapping.h"
#import "Models/Friend+Mapping.h"
#import "Models/Notification.h"

@implementation API

static NSString *const RYWebserviceUrl = @"http://a.staging.raceyourself.com/";
static NSString *const RYApiUrl = @"http://a.staging.raceyourself.com/api/1/";
static NSString *const RYClientId = @"c9842247411621e35dbaf21ad0e15c263364778bf9a46b5e93f64ff2b6e0e17c";
static NSString *const RYClientSecret = @"75f3e999c01942219bea1e9c0a1f76fd24c3d55df6b1c351106cc686f7fcd819";

static NSMutableArray *loginCallbacks = nil;
static NSMutableArray *syncCallbacks = nil;

static NSThread *syncThread = nil;

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

+ (void)addSyncCallback:(BOOL(^)(NSString *state))callback
{
  if (syncCallbacks == nil) syncCallbacks = [NSMutableArray new];
  [syncCallbacks addObject:callback];
}

+ (void)onSync:(NSString *)state
{
  NSMutableArray *completedCallbacks = [NSMutableArray new];
  for (BOOL(^callback)(NSString *state) in syncCallbacks) {
    if (callback(state) == YES) {
      [completedCallbacks addObject:callback];
    }
  }
  [syncCallbacks removeObjectsInArray:completedCallbacks];
}

+ (void)fetchRoute:(NSString*)route forType:(Class)type withCallback:(void(^)(id object))callback
{
    AccessToken *at = [AccessToken MR_findFirst];
    if (at == nil || [at.expiration_time timeIntervalSinceDate:[NSDate date]] <= 0) {
      callback(nil);
    }

    NSLog(@"API:fetching route %@ for %@", route, type);

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[RYApiUrl stringByAppendingString:route]]];
    [request setValue:[@"Bearer " stringByAppendingString:at.access_token] forHTTPHeaderField:@"Authorization"];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
      NSLog(@"API:fetch(%@, %@) cached for 0 seconds", route, type);
      id object = [type MR_importFromObject:[JSON objectForKey:@"response"]];
      callback(object);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      NSLog(@"API:fetch(%@, %@) failed with %@", route, type, [error localizedDescription]);
      callback(nil);
    }];

    [operation start];
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
    [AccessToken MR_truncateAll]; // There can be only one!
    AccessToken *token = [AccessToken MR_createEntity];
    token.access_token = [JSON objectForKey:@"access_token"];
    int expires_in = [[JSON objectForKey:@"expires_in"] intValue];
    token.expiration_time = [[NSDate date] dateByAddingTimeInterval:expires_in];
    NSLog(@"API:loginWithUsername(%@) received an access token", username);

    [API fetchRoute:@"me" forType:[User class] withCallback:^void (id object) {
      if (object != nil) {
        User *user = (User*)object;
        token.user = user;
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait]; 
        NSLog(@"API:loginWithUsername(%@) succeeded; user_id: %@", username, user.id);
        [API onLogin:@"success"];
      } else {
        NSLog(@"API:loginWithUsername(%@) failed to fetch logged-in user", username);
        [API onLogin:@"failure"];
      }
    }];
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"API:loginWithUsername(%@) failed with %@", username, [error localizedDescription]);
    [API onLogin:@"failure"];
  }];

  [operation start];
}

+ (void)syncWithCallback:(BOOL(^)(NSString *state))callback
{
  [API addSyncCallback:callback];
  [API sync];
}

+ (void)sync
{
  if (syncThread != nil && [syncThread isExecuting] == YES) {
    NSLog(@"API:sync is already running");
    return;
  }
  // TODO: NSOperation?
  syncThread = [[NSThread alloc] initWithTarget:self
                                       selector:@selector(internalSync)
                                         object:nil];
  [syncThread start];
}

+ (NSArray*)importFromArray:(NSArray*)listOfObjectData withType:(Class)type
{
  NSMutableArray *dataObjects = [NSMutableArray array];

  [listOfObjectData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
  {
      NSDictionary *objectData = (NSDictionary *)obj;

      NSManagedObject *dataObject = [type MR_importFromObject:objectData];

      [dataObjects addObject:dataObject];
  }];

  return dataObjects;
}

+ (void)internalSync
{
  NSString *state = @"failure";
  @try {
    AccessToken *at = [AccessToken MR_findFirst];
    if (at == nil || [at.expiration_time timeIntervalSinceDate:[NSDate date]] <= 0) {
      NSLog(@"API:sync failed: no valid access token");
      state = @"unauthorized";
      return;
    }

    // TODO: Load from db
    int timestamp = 0;

    NSLog(@"API:syncing from timstamp %d", timestamp);

    NSData *postData = [@"{\"data\":{}}" dataUsingEncoding:NSUTF8StringEncoding];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[RYApiUrl stringByAppendingFormat:@"sync/%d", timestamp]]];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    [request setHTTPMethod:@"POST"];
    [request setValue:[@"Bearer " stringByAppendingString:at.access_token] forHTTPHeaderField:@"Authorization"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
      NSString *state = @"failure";
      @try {
        id response = [JSON objectForKey:@"response"];
        NSArray *ufriendships = [API importFromArray:[response objectForKey:@"friends"] withType:[Friendship class]];
        NSLog(@"synced %d friends", [ufriendships count]);
        NSArray *challenges = [API importFromArray:[response objectForKey:@"challenges"] withType:[Challenge class]];
        NSLog(@"synced %d challenges", [challenges count]);
        NSArray *notifications = [API importFromArray:[response objectForKey:@"notifications"] withType:[Notification class]];
        NSLog(@"synced %d notifications", [notifications count]);
        NSArray *users = [API importFromArray:[response objectForKey:@"users"] withType:[User class]];
        NSLog(@"synced %d users", [users count]);
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait]; 
        NSLog(@"API:sync succeeded");
        state = @"full";
      }
      @finally {
        [API onSync:state];
        syncThread = nil;
      }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      NSLog(@"API:sync failed with %@", [error localizedDescription]);
      [API onSync:@"failure"];
      syncThread = nil;
    }];

    [operation start];
  }
  @catch (NSException * e) {
    [API onSync:state];
    syncThread = nil;
  }
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
