//
//  Friendship.h
//  Platform
//
//  Created by Janne Husberg on 08/07/2014.
//  Copyright (c) 2014 raceyourself. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Friend;

@interface Friendship : NSManagedObject

@property (nonatomic, retain) NSDate * deleted_at;
@property (nonatomic, retain) NSString * identity_type;
@property (nonatomic, retain) NSString * identity_uid;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) Friend *friend;

@end
