//
//  Created by Dima on 25.03.12.
//


#import <CoreLocation/CoreLocation.h>
#import "Helpers.h"
#import "Models.h"

/******************************************************************************/

@implementation Closing

#pragma mark - properties

@synthesize time;
@synthesize crossing;
@synthesize direction;
@synthesize timeInMinutes;

- (int)stopTimeInMinutes {
  return timeInMinutes - 10;
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

  Closing *closing = [Closing new];
  closing.crossing = crossing;
  closing.time = time;
  closing.timeInMinutes = [Helper parseStringAsHHMM:time];
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


// - осталось более часа — зеленый
// - осталось примерно 55/50/.../20 минут — желтый
// - осталось примерно 15/10/5 минут — красный
// - вероятно уже закрыт — красный
// - Аллегро только что прошел — желтый
- (CrossingState)state {
  int nextClosingTime = self.nextClosing.stopTimeInMinutes;
  int prevClosingTime = self.previousClosing.timeInMinutes;
  int nextTrainTime = self.nextClosing.timeInMinutes;
  int timeTillNextClosing = self.minutesTillNextClosing;
  int currentTime = Helper.currentTimeInMinutes;

  if (prevClosingTime <= currentTime && currentTime - prevClosingTime < 10) return CrosingsStateJustOpened;
  if (nextTrainTime < currentTime) return CrossingStateClear; // next train will be tomorrow
  if (nextClosingTime < currentTime) return CrossingStateClosed; // just closed
  if (timeTillNextClosing > 60) return CrossingStateClear;
  if (timeTillNextClosing > 20) return CrossingStateSoon;
  if (timeTillNextClosing >  5) return CrossingStateVerySoon;
  if (timeTillNextClosing >  0) return CrossingStateClosing;
  return CrossingStateClosed;
}

- (Closing *)nextClosing {
  int currentTime = [Helper currentTimeInMinutes];

  for (Closing *closing in self.closings) {
    if (closing.timeInMinutes >= currentTime)
      return closing;
  }

  return self.closings.firstObject;
}

- (Closing *)previousClosing {
  int currentTime = [Helper currentTimeInMinutes];

  for (Closing *closing in self.closings.reverseObjectEnumerator) {
    if (closing.timeInMinutes < currentTime)
      return closing;
  }

  return self.closings.lastObject;
}

- (int)minutesTillNextClosing {
  int nextClosingTime = self.nextClosing.stopTimeInMinutes;
  int currentTime = [Helper currentTimeInMinutes];
  if (nextClosingTime > currentTime) {
    return nextClosingTime -  currentTime;
  } else {
    return 24 * 60 + nextClosingTime - currentTime;
  }
}

- (BOOL)isClosest {
  return self == model.closestCrossing;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"Crossing(%@, %f, %f, %dn)", name, latitude, longitude, closings.count];
}

#pragma mark - static

+ (Crossing *)crossingWithName:(NSString *)name latitude:(double)lat longitude:(double)lng {
  Crossing *const crossing = [self new];
  crossing.name = name;
  crossing.latitude = (float) lat;
  crossing.longitude = (float) lng;
  crossing.closings = [NSMutableArray arrayWithCapacity:8];
  return crossing;
}

+ (Crossing *)getCrossingWithName:(NSString *)name {
  for (Crossing *crossing in model.crossings) {
    if ([crossing.name isEqualToString:name])
      return crossing;
  }

  NSLog(@"[%s] crossing is not found for name = '%@'", sel_getName(_cmd), name);

  return nil;
}

@end

/******************************************************************************/

@implementation ModelManager

#pragma mark - properties

@synthesize crossings;
@synthesize closings;
@synthesize closestCrossing;
@synthesize selectedCrossing;

- (Crossing *)defaultCrossing {
  return [Crossing getCrossingWithName:@"Удельная"];
}

- (Crossing *)closestCrossing {
  if (!closestCrossing) {
    CLLocation *location = [[CLLocationManager new] location];
    if (location)
      closestCrossing = [self crossingClosestTo:location];
  }
  return closestCrossing;
}

- (Crossing *)currentCrossing {
  if (self.selectedCrossing) return self.selectedCrossing;
  if (self.closestCrossing) return self.closestCrossing;
  return self.defaultCrossing;
}

- (Crossing *)selectedCrossing {
  NSString *crossingName = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedCrossing"];
  return crossingName ? [Crossing getCrossingWithName:crossingName] : nil;
}

- (void)setSelectedCrossing:(Crossing *)aCrossing {
  [[NSUserDefaults standardUserDefaults] setObject:aCrossing.name forKey:@"selectedCrossing"];
}

#pragma mark - methods

- (Crossing *)crossingClosestTo:(CLLocation *)location {
  return [crossings minimumObject:^(Crossing *crossing){
    CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:crossing.latitude longitude:crossing.longitude];
    double distance = [currentLocation distanceFromLocation:location];
    return distance;
  }];
}

#pragma mark - initialization

+ (void)prepare {
  model = [ModelManager alloc];
  model = [model init];
}

- (id)init {
  self = [super init];

  crossings = [NSMutableArray arrayWithObjects:
      [Crossing crossingWithName:@"Удельная" latitude:60.017533 longitude:30.313379],
      [Crossing crossingWithName:@"Поклонногорская" latitude:60.025533 longitude:30.309113],
      [Crossing crossingWithName:@"Озерки - Шувалово" latitude:60.042087 longitude:30.300095],
      [Crossing crossingWithName:@"Дорога на Каменку" latitude:60.070331 longitude:30.275285],
      [Crossing crossingWithName:@"Парголово" latitude:60.079674 longitude:30.260536],
      [Crossing crossingWithName:@"Песочная" latitude:60.118323 longitude:30.147631],
      [Crossing crossingWithName:@"Дибуны" latitude:60.121706 longitude:30.130231],
      nil];

  closings = [NSMutableArray arrayWithObjects:
      [Closing closingWithCrossingName:@"Удельная" time:@"06:57" direction:ClosingDirectionToFinland],  // inconsistent
      [Closing closingWithCrossingName:@"Удельная" time:@"11:32" direction:ClosingDirectionToFinland],
      [Closing closingWithCrossingName:@"Удельная" time:@"15:32" direction:ClosingDirectionToFinland],
      [Closing closingWithCrossingName:@"Удельная" time:@"20:32" direction:ClosingDirectionToFinland],
      [Closing closingWithCrossingName:@"Удельная" time:@"10:36" direction:ClosingDirectionToRussia],
      [Closing closingWithCrossingName:@"Удельная" time:@"14:21" direction:ClosingDirectionToRussia],
      [Closing closingWithCrossingName:@"Удельная" time:@"19:21" direction:ClosingDirectionToRussia],
      [Closing closingWithCrossingName:@"Удельная" time:@"23:21" direction:ClosingDirectionToRussia],
      [Closing closingWithCrossingName:@"Поклонногорская" time:@"06:47" direction:ClosingDirectionToFinland], // inconsistent
      [Closing closingWithCrossingName:@"Поклонногорская" time:@"11:33" direction:ClosingDirectionToFinland],
      [Closing closingWithCrossingName:@"Поклонногорская" time:@"15:33" direction:ClosingDirectionToFinland],
      [Closing closingWithCrossingName:@"Поклонногорская" time:@"20:33" direction:ClosingDirectionToFinland],
      [Closing closingWithCrossingName:@"Поклонногорская" time:@"10:35" direction:ClosingDirectionToRussia],
      [Closing closingWithCrossingName:@"Поклонногорская" time:@"14:20" direction:ClosingDirectionToRussia],
      [Closing closingWithCrossingName:@"Поклонногорская" time:@"19:20" direction:ClosingDirectionToRussia],
      [Closing closingWithCrossingName:@"Поклонногорская" time:@"23:20" direction:ClosingDirectionToRussia],
      [Closing closingWithCrossingName:@"Озерки - Шувалово" time:@"12:00" direction:ClosingDirectionToFinland],
      [Closing closingWithCrossingName:@"Озерки - Шувалово" time:@"15:00" direction:ClosingDirectionToFinland],
      [Closing closingWithCrossingName:@"Озерки - Шувалово" time:@"18:00" direction:ClosingDirectionToFinland],
      [Closing closingWithCrossingName:@"Озерки - Шувалово" time:@"21:00" direction:ClosingDirectionToFinland],
      [Closing closingWithCrossingName:@"Озерки - Шувалово" time:@"12:00" direction:ClosingDirectionToRussia],
      [Closing closingWithCrossingName:@"Озерки - Шувалово" time:@"15:00" direction:ClosingDirectionToRussia],
      [Closing closingWithCrossingName:@"Озерки - Шувалово" time:@"18:00" direction:ClosingDirectionToRussia],
      [Closing closingWithCrossingName:@"Озерки - Шувалово" time:@"21:00" direction:ClosingDirectionToRussia],
      [Closing closingWithCrossingName:@"Дибуны" time:@"06:57" direction:ClosingDirectionToFinland],
      [Closing closingWithCrossingName:@"Дибуны" time:@"11:32" direction:ClosingDirectionToFinland],
      [Closing closingWithCrossingName:@"Дибуны" time:@"15:32" direction:ClosingDirectionToFinland],
      [Closing closingWithCrossingName:@"Дибуны" time:@"20:32" direction:ClosingDirectionToFinland],
      [Closing closingWithCrossingName:@"Дибуны" time:@"10:36" direction:ClosingDirectionToRussia],
      [Closing closingWithCrossingName:@"Дибуны" time:@"14:21" direction:ClosingDirectionToRussia],
      [Closing closingWithCrossingName:@"Дибуны" time:@"19:21" direction:ClosingDirectionToRussia],
      [Closing closingWithCrossingName:@"Дибуны" time:@"23:21" direction:ClosingDirectionToRussia],
      nil];

  for (Crossing *crossing in crossings) {
    [crossing.closings sortUsingComparator:^NSComparisonResult(Closing *obj1, Closing *obj2) {
      return [Helper compareInteger:obj1.timeInMinutes with:obj2.timeInMinutes];
    }];
  }

  return self;
}

@end
