//
//  Created by Dima on 25.03.12.
//


#import "Models.h"

static NSMutableArray *gAllCrossings;
static NSMutableArray *gAllClosings;

@implementation Closing
@synthesize time;
@synthesize crossing;
@synthesize direction;

- (NSString *)soonestTime {
  return nil;
}

+ (void)seed {
  gAllClosings = [NSMutableArray arrayWithObjects:
      [Closing closingWithCrossingName:@"Удельнав" time:@"12:00" direction:ClosingDirectionToFinland],
      [Closing closingWithCrossingName:@"Удельнав" time:@"15:00" direction:ClosingDirectionToFinland],
      [Closing closingWithCrossingName:@"Удельнав" time:@"18:00" direction:ClosingDirectionToFinland],
      [Closing closingWithCrossingName:@"Удельнав" time:@"21:00" direction:ClosingDirectionToFinland],
      [Closing closingWithCrossingName:@"Удельнав" time:@"12:00" direction:ClosingDirectionToRussia],
      [Closing closingWithCrossingName:@"Удельнав" time:@"15:00" direction:ClosingDirectionToRussia],
      [Closing closingWithCrossingName:@"Удельнав" time:@"18:00" direction:ClosingDirectionToRussia],
      [Closing closingWithCrossingName:@"Удельнав" time:@"21:00" direction:ClosingDirectionToRussia],

      [Closing closingWithCrossingName:@"Поклонногорская" time:@"12:00" direction:ClosingDirectionToFinland],
      [Closing closingWithCrossingName:@"Поклонногорская" time:@"15:00" direction:ClosingDirectionToFinland],
      [Closing closingWithCrossingName:@"Поклонногорская" time:@"18:00" direction:ClosingDirectionToFinland],
      [Closing closingWithCrossingName:@"Поклонногорская" time:@"21:00" direction:ClosingDirectionToFinland],
      [Closing closingWithCrossingName:@"Поклонногорская" time:@"12:00" direction:ClosingDirectionToRussia],
      [Closing closingWithCrossingName:@"Поклонногорская" time:@"15:00" direction:ClosingDirectionToRussia],
      [Closing closingWithCrossingName:@"Поклонногорская" time:@"18:00" direction:ClosingDirectionToRussia],
      [Closing closingWithCrossingName:@"Поклонногорская" time:@"21:00" direction:ClosingDirectionToRussia],

      [Closing closingWithCrossingName:@"Озерки - Шувалово" time:@"12:00" direction:ClosingDirectionToFinland],
      [Closing closingWithCrossingName:@"Озерки - Шувалово" time:@"15:00" direction:ClosingDirectionToFinland],
      [Closing closingWithCrossingName:@"Озерки - Шувалово" time:@"18:00" direction:ClosingDirectionToFinland],
      [Closing closingWithCrossingName:@"Озерки - Шувалово" time:@"21:00" direction:ClosingDirectionToFinland],
      [Closing closingWithCrossingName:@"Озерки - Шувалово" time:@"12:00" direction:ClosingDirectionToRussia],
      [Closing closingWithCrossingName:@"Озерки - Шувалово" time:@"15:00" direction:ClosingDirectionToRussia],
      [Closing closingWithCrossingName:@"Озерки - Шувалово" time:@"18:00" direction:ClosingDirectionToRussia],
      [Closing closingWithCrossingName:@"Озерки - Шувалово" time:@"21:00" direction:ClosingDirectionToRussia],

      nil];
}

+ (id)closingWithCrossingName:(NSString *)crossingName time:(NSString *)time direction:(ClosingDirection)direction {
  Crossing *crossing = [Crossing getCrossingWithName:crossingName];
  Closing *closing = [[Closing alloc] init];
  closing.crossing = crossing;
  closing.time = time;
  closing.direction = direction;
  [crossing.closings addObject:closing];
  return crossing;
}
@end

@implementation Crossing : NSObject
@synthesize name;
@synthesize latitude;
@synthesize longitude;
@synthesize closings;

+ (void)seed {
  gAllCrossings = [NSMutableArray arrayWithObjects:
      [Crossing crossingWithName:@"Удельнав"],
      [Crossing crossingWithName:@"Поклонногорская"],
      [Crossing crossingWithName:@"Озерки - Шувалово"],
      [Crossing crossingWithName:@"Дорога на Каменку"],
      [Crossing crossingWithName:@"Парголово"],
      [Crossing crossingWithName:@"Песочная"],
      [Crossing crossingWithName:@"Дибуны"],
      nil];
}

+ (Crossing *)crossingWithName:(NSString *)aName {
  Crossing *const crossing = [[self alloc] init];
  crossing.name = aName;
  return crossing;
}

+ (Crossing *)getCrossingWithName:(NSString *)name {
  for (Crossing *crossing in gAllCrossings) {
    if ([crossing.name isEqualToString:name])
      return crossing;
  }

  NSAssert(NO, @"Crossing should always be found");
  return nil;
}
@end

@implementation ModelManager

+ (void)initialize {
  [Closing seed];
  [Crossing seed];
}

+ (Crossing *)closestCrossing {
  return [Crossing getCrossingWithName:@"Удельная"];
}

+ (Crossing *)currentCrossing {
  return [self closestCrossing];
}
+ (NSString *)geolocationState {
  return @"Unknown";
}

@end
