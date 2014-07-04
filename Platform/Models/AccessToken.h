//
//  AccessToken.h
//  Platform
//
//  Created by JanneH on 04/07/2014.
//  Copyright (c) 2014 raceyourself. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AccessToken : NSManagedObject

@property (nonatomic, retain) NSString * access_token;
@property (nonatomic, retain) NSDate * expiration_time;

@end
