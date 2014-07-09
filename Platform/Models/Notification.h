//
//  Notification.h
//  Platform
//
//  Created by Janne Husberg on 09/07/2014.
//  Copyright (c) 2014 raceyourself. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Notification : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * read;
@property (nonatomic, retain) id message;
@property (nonatomic, retain) NSDate * deleted_at;

@end
