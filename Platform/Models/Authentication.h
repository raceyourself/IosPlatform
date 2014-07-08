//
//  Authentication.h
//  Platform
//
//  Created by Janne Husberg on 08/07/2014.
//  Copyright (c) 2014 raceyourself. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Authentication : NSManagedObject

@property (nonatomic, retain) NSString * provider;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * permissions;
@property (nonatomic, retain) User *user;

@end
