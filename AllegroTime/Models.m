//
//  Created by Dima on 25.03.12.
//


#import "Helpers.h"
#import "Models.h"

static NSMutableArray *ModelManagerCrossings;
static NSMutableArray *ModelManagerClosings;

/******************************************************************************/

@implementation Closing

#pragma mark - properties

@synthesize time;
@synthesize crossing;
@synthesize direction;
@synthesize timeInMinutes;

- (NSString *)soonestTime {
  return @"12:55";
}

- (NSString *)directionCode {
  if (direction == ClosingDirectionToFinland)
    return @"FIN";
  else if (direction == ClosingDirectionToRussia)
    return @"RUS";
  else
    return @"N/A";
}

- (NSString *)description {
  return [NSString stringWithFormat:@"Closing(%@, %@, %@)", crossing.name, time, self.directionCode];
}

#pragma mark - static

+ (id)closingWithCrossingName:(NSString *)crossingName time:(NSString *)time direction:(ClosingDirection)direction {
  Crossing *crossing = [Crossing getCrossingWithName:crossingName];

  Closing *closing = [[Closing alloc] init];
  closing.crossing = crossing;
  closing.time = time;
  closing.timeInMinutes = [Helpers parseStringAsHHMM:time];
  closing.direction = direction;

  [crossing.closings addObject:closing];

  return closing;
}

@end

/******************************************************************************/

@implementation Crossing : NSObject

#pragma mark - properties

@synthesize name;
@synthesize latitude;
@synthesize longitude;
@synthesize closings;

- (Closing *)nextClosing {
  int currentTime = [Helpers currentTimeInMinutes];

  NSLog(@"currentTime = %li", currentTime);


  for (Closing *closing in self.closings) {
    NSLog(@"closing.timeInMinutes = %li", closing.timeInMinutes);

    if (closing.timeInMinutes > currentTime)
      return closing;
  }

  return self.closings.firstObject;
}

- (NSString *)nextTime {
  return self.nextClosing.time;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"Crossing(%@, %f, %f, %dn)", name, latitude, longitude, closings.count];
}

#pragma mark - static

+ (Crossing *)crossingWithName:(NSString *)name latitude:(double)lat longitude:(double)lng {
  Crossing *const crossing = [[self alloc] init];
  crossing.name = name;
  crossing.latitude = (float) lat;
  crossing.longitude = (float) lng;
  crossing.closings = [NSMutableArray arrayWithCapacity:8];
  return crossing;
}

+ (Crossing *)getCrossingWithName:(NSString *)name {
  for (Crossing *crossing in ModelManager.Crossings) {
    if ([crossing.name isEqualToString:name])
      return crossing;
  }

  NSAssert(NO, [@"Crossing should always be found, name = " stringByAppendingString:name]);
  return nil;
}

@end

/******************************************************************************/

@implementation ModelManager

#pragma mark - app state

+ (NSMutableArray *)Crossings {
  return ModelManagerCrossings;
}

+ (NSMutableArray *)closings {
  return ModelManagerClosings;
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

#pragma mark - app initialization

+ (void)prepare {
  [self createData];

  //gLog("allCrossings", [ModelManager allCrossings]);
  //gLog("allClosings", [ModelManager allClosings]);
  gLog("current", [ModelManager closestCrossing]);
}

+ (void)createData {
  ModelManagerCrossings = [NSMutableArray arrayWithObjects:
      [Crossing crossingWithName:@"Удельная" latitude:60.017533 longitude:30.313379],
      [Crossing crossingWithName:@"Поклонногорская" latitude:60.025533 longitude:30.309113],
      [Crossing crossingWithName:@"Озерки - Шувалово" latitude:60.042087 longitude:30.300095],
      [Crossing crossingWithName:@"Дорога на Каменку" latitude:60.070331 longitude:30.275285],
      [Crossing crossingWithName:@"Парголово" latitude:60.079674 longitude:30.260536],
      [Crossing crossingWithName:@"Песочная" latitude:60.118323 longitude:30.147631],
      [Crossing crossingWithName:@"Дибуны" latitude:60.121706 longitude:30.130231],
      nil];

  ModelManagerClosings = [NSMutableArray arrayWithObjects:
      [Closing closingWithCrossingName:@"Удельная" time:@"12:00" direction:ClosingDirectionToFinland],
      [Closing closingWithCrossingName:@"Удельная" time:@"15:00" direction:ClosingDirectionToFinland],
      [Closing closingWithCrossingName:@"Удельная" time:@"18:00" direction:ClosingDirectionToFinland],
      [Closing closingWithCrossingName:@"Удельная" time:@"21:00" direction:ClosingDirectionToFinland],
      [Closing closingWithCrossingName:@"Удельная" time:@"12:00" direction:ClosingDirectionToRussia],
      [Closing closingWithCrossingName:@"Удельная" time:@"15:00" direction:ClosingDirectionToRussia],
      [Closing closingWithCrossingName:@"Удельная" time:@"18:00" direction:ClosingDirectionToRussia],
      [Closing closingWithCrossingName:@"Удельная" time:@"21:00" direction:ClosingDirectionToRussia],
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

  [ModelManagerClosings sortUsingComparator:^NSComparisonResult(Closing *obj1, Closing *obj2) {
    return [Helpers compareInteger:obj1.timeInMinutes with:obj2.timeInMinutes];
  }];
}


@end
