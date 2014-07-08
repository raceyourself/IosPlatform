#import "User+Mapping.h"


@implementation User (Mapping)

- (BOOL) shouldImportAuthentications:(id)data
{
  // Overwrite authentications (clear+import)
  self.authentications = [NSSet set];
  return YES;
}

@end
