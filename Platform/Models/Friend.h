//
//  Friend.h
//  Platform
//
//  Created by Janne Husberg on 09/07/2014.
//  Copyright (c) 2014 raceyourself. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Friendship;

@interface Friend : NSManagedObject

@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * photo;
@property (nonatomic, retain) NSString * provider;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) Friendship *friendship;

@end
