//
//  Challenge.h
//  Platform
//
//  Created by Janne Husberg on 09/07/2014.
//  Copyright (c) 2014 raceyourself. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Challenge : NSManagedObject

@property (nonatomic, retain) NSNumber * accepted;
@property (nonatomic, retain) NSNumber * creator_id;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * points_awarded;
@property (nonatomic, retain) NSString * prize;
@property (nonatomic, retain) NSNumber * public;
@property (nonatomic, retain) NSDate * start_time;
@property (nonatomic, retain) NSDate * stop_time;
@property (nonatomic, retain) NSString * type;

@end
