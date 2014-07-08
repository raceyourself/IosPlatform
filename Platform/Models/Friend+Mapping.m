#import "Friend+Mapping.h"


@implementation Friend (Mapping)

- (NSString*)id 
{
  [self willAccessValueForKey:@"id"];

  NSString *id = [@[self.provider, self.uid] componentsJoinedByString:@"-"];

  [self didAccessValueForKey:@"id"];

  return id;
}

+ (id)extractPKFromObject:(id)data
{
  return [@[[data objectForKey:@"provider"], [data objectForKey:@"uid"]] componentsJoinedByString:@"-"];
}

@end
