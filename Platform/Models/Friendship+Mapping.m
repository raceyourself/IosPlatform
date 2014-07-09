#import "Friendship+Mapping.h"
#import "Friend+Mapping.h"


@implementation Friendship (Mapping)

- (BOOL) shouldImportFriend:(id)data
{
  if (self.friend != nil) {
    [self.friend MR_deleteEntity];
  }
  return YES;
}

@end
