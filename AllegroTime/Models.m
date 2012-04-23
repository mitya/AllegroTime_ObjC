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

- (BOOL)toRussia {
  return self.direction == ClosingDirectionToRussia;
}

- (int)trainNumber {
  int position = [self.crossing.closings indexOfObject:self];
  return 150 + 1 + position;
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

- (CrossingState)state {
  return self.crossing.state;
}

- (BOOL)isClosest {
  Closing *const nextClosing = self.crossing.nextClosing;
  Closing *const previousClosing = self.crossing.previousClosing;
  int currentTime = Helper.currentTimeInMinutes;
  if (previousClosing.timeInMinutes <= currentTime && currentTime - previousClosing.timeInMinutes < PREVIOUS_TRAIN_LAG_TIME) {
    return self == previousClosing;
  } else {
    return self == nextClosing;
  }
}

- (UIColor *)color {
  return self.crossing.color;
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

@implementation Crossing

#pragma mark - properties

@synthesize name;
@synthesize latitude;
@synthesize longitude;
@synthesize closings;
@synthesize distance;

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

  if (prevClosingTime <= currentTime && currentTime - prevClosingTime < PREVIOUS_TRAIN_LAG_TIME) return CrosingsStateJustOpened;
  if (nextTrainTime < currentTime) return CrossingStateClear; // next train will be tomorrow
  if (nextClosingTime < currentTime) return CrossingStateClosed; // just closed
  if (timeTillNextClosing > 60) return CrossingStateClear;
  if (timeTillNextClosing > 20) return CrossingStateSoon;
  if (timeTillNextClosing > 5) return CrossingStateVerySoon;
  if (timeTillNextClosing > 0) return CrossingStateClosing;

  return CrossingStateClosed;
}

- (UIColor *)color {
  switch (self.state) {
    case CrossingStateClear:
      return [UIColor greenColor];
    case CrossingStateSoon:
      return [UIColor greenColor];
    case CrossingStateVerySoon:
      return [UIColor redColor];
    case CrossingStateClosing:
      return [UIColor redColor];
    case CrossingStateClosed:
      return [UIColor redColor];
    case CrosingsStateJustOpened:
      return [UIColor yellowColor];
    default:
      return [UIColor greenColor];
  }
}

- (CLLocationCoordinate2D)coordinate {
  return CLLocationCoordinate2DMake(latitude, longitude);
}

- (NSString *)title {
  return [NSString stringWithFormat:@"%@, %i км", self.name, self.distance];
}

- (NSString *)subtitle {
  switch (self.state) {
    case CrossingStateClear:
    case CrossingStateSoon:
    case CrossingStateVerySoon:
    case CrossingStateClosing:
    case CrossingStateClosed:
      return [NSString stringWithFormat:@"Следующий пройдет через %i минут", self.minutesTillNextClosing];
    case CrosingsStateJustOpened:
      return [NSString stringWithFormat:@"Предыдущий только что ушел"];
    default:
      return nil;
  }

  //switch (self.state) {
  //    case CrossingStateClear:
  //        return @"До закрытия более часа";
  //    case CrossingStateSoon:
  //        return [NSString stringWithFormat:@"До закрытия около %i минут", [Helper roundToFive:model.currentCrossing.minutesTillNextClosing]];
  //    case CrossingStateVerySoon:
  //        return [NSString stringWithFormat:@"До закрытия около %i минут", [Helper roundToFive:model.currentCrossing.minutesTillNextClosing]];
  //    case CrossingStateClosing:
  //        return @"Сейчас закроют";
  //    case CrossingStateClosed:
  //        return @"Переезд закрыт";
  //    case CrosingsStateJustOpened:
  //        return @"Переезд только что открыли";
  //    default:
  //        return nil;
  //}
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
    return nextClosingTime - currentTime;
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

- (void)addClosingWithTime:(NSString *)time direction:(ClosingDirection)direction {
  Closing *closing = [Closing new];
  closing.crossing = self;
  closing.time = time;
  closing.timeInMinutes = [Helper parseStringAsHHMM:time];
  closing.direction = direction;
  [self.closings addObject:closing];
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

@synthesize locationManager;
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
  return [crossings minimumObject:^(Crossing *crossing) {
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
  [self loadFile];
  return self;
}

- (void)loadFile {
  crossings = [NSMutableArray arrayWithCapacity:30];

  NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"Data/Schedule" ofType:@"csv"];
  NSString *dataString = [NSString stringWithContentsOfFile:dataPath encoding:NSUTF8StringEncoding error:NULL];
  NSArray *dataRows = [dataString componentsSeparatedByString:@"\n"];

  for (NSString *dataRow in dataRows) {
    NSArray *components = [dataRow componentsSeparatedByString:@","];

    Crossing *crossing = [Crossing new];
    crossing.name = [components objectAtIndex:0];
    crossing.distance = [[components objectAtIndex:1] intValue];
    crossing.latitude = [[components objectAtIndex:2] floatValue];
    crossing.longitude = [[components objectAtIndex:3] floatValue];
    crossing.closings = [NSMutableArray arrayWithCapacity:8];

    unsigned int lastDatumIndex = 3;
    [crossing addClosingWithTime:[components objectAtIndex:lastDatumIndex + 1] direction:ClosingDirectionToFinland];
    [crossing addClosingWithTime:[components objectAtIndex:lastDatumIndex + 2] direction:ClosingDirectionToRussia];
    [crossing addClosingWithTime:[components objectAtIndex:lastDatumIndex + 3] direction:ClosingDirectionToFinland];
    [crossing addClosingWithTime:[components objectAtIndex:lastDatumIndex + 4] direction:ClosingDirectionToRussia];
    [crossing addClosingWithTime:[components objectAtIndex:lastDatumIndex + 5] direction:ClosingDirectionToFinland];
    [crossing addClosingWithTime:[components objectAtIndex:lastDatumIndex + 6] direction:ClosingDirectionToRussia];
    [crossing addClosingWithTime:[components objectAtIndex:lastDatumIndex + 7] direction:ClosingDirectionToFinland];
    [crossing addClosingWithTime:[components objectAtIndex:lastDatumIndex + 8] direction:ClosingDirectionToRussia];

    [crossings addObject:crossing];
  }

  closings = [NSMutableArray arrayWithCapacity:crossings.count * 8];
  for (Crossing *crossing in crossings) {
    [closings addObjectsFromArray:crossing.closings];
  }
}
@end
