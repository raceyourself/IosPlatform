//
//  API.h
//  Platform
//
//  Created by Janne Husberg on 07/07/2014.
//  Copyright (c) 2014 raceyourself. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface API : NSObject

+ (void)loginWithUsername:(NSString *)username withPassword:(NSString *)password;
+ (void)loginWithUsername:(NSString *)username withPassword:(NSString *)password
                                               withCallback:(BOOL(^)(NSString *state))callback;

+ (void)sync;
+ (void)syncWithCallback:(BOOL(^)(NSString *state))callback;

@end
