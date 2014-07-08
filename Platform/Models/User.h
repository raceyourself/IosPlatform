//
//  User.h
//  Platform
//
//  Created by Janne Husberg on 08/07/2014.
//  Copyright (c) 2014 raceyourself. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Authentication;

@interface User : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSNumber * timezone;
@property (nonatomic, retain) NSNumber * points;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) id profile;
@property (nonatomic, retain) NSSet *authentications;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addAuthenticationsObject:(Authentication *)value;
- (void)removeAuthenticationsObject:(Authentication *)value;
- (void)addAuthentications:(NSSet *)values;
- (void)removeAuthentications:(NSSet *)values;

@end
