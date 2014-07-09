//
//  AccessToken.h
//  Platform
//
//  Created by Janne Husberg on 09/07/2014.
//  Copyright (c) 2014 raceyourself. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface AccessToken : NSManagedObject

@property (nonatomic, retain) NSString * access_token;
@property (nonatomic, retain) NSDate * expiration_time;
@property (nonatomic, retain) User *user;

@end
