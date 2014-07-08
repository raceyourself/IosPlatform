#import "Friendship+Mapping.h"
#import "Friend+Mapping.h"


@implementation Friendship (Mapping)

- (NSString*)id                                                                           
{
  [self willAccessValueForKey:@"id"];
  
  NSString *id = self.friend.id;

  [self didAccessValueForKey:@"id"];

  return id;
}

+ (id)extractPKFromObject:(id)data
{
  // TODO: Remove Friendship model from coredata
  return [Friend extractPKFromObject:[data objectForKey:@"friend"]];
}

@end
