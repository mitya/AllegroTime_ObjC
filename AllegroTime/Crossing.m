#import <CoreLocation/CoreLocation.h>
#import "Helpers.h"
#import "Models.h"

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
  int currentTime = MXCurrentTimeInMinutes();
  int trainTime = self.currentClosing.trainTime;

  if (currentTime > trainTime + PREVIOUS_TRAIN_LAG_TIME) return CrossingStateClear; // next train will be tomorrow
  if (currentTime >= trainTime && currentTime <= trainTime + PREVIOUS_TRAIN_LAG_TIME) return CrosingsStateJustOpened;
  if (currentTime >= trainTime - CLOSING_TIME && currentTime < trainTime) return CrossingStateClosed;

  int timeTillClosing = trainTime - CLOSING_TIME - currentTime;

  if (timeTillClosing > 60) return CrossingStateClear;
  if (timeTillClosing > 20) return CrossingStateSoon;
  if (timeTillClosing > 5) return CrossingStateVerySoon;
  if (timeTillClosing > 0) return CrossingStateClosing;

  return CrossingStateClosed;
}

- (UIColor *)color {
  switch (self.state) {
    case CrossingStateClear:
      return [UIColor greenColor];
    case CrossingStateSoon:
      return [UIColor greenColor];
    case CrossingStateVerySoon:
      return [UIColor yellowColor];
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
      return MXFormatMinutesAsTextWithZero(self.minutesTillClosing, @"Закроют через %@", @"Только что закрыли");
    case CrossingStateClosed:
      return MXFormatMinutesAsTextWithZero(self.minutesTillOpening, @"Откроют через %@", @"Только что открыли");
    case CrosingsStateJustOpened:
      return MXFormatMinutesAsTextWithZero(self.minutesSinceOpening, @"Открыли %@ назад", @"Только что открыли");
    default:
      return nil;
  }
}

- (Closing *)nextClosing {
  int currentTime = MXCurrentTimeInMinutes();

  for (Closing *closing in self.closings) {
    if (closing.trainTime >= currentTime)
      return closing;
  }

  return self.closings.firstObject;
}

- (Closing *)previousClosing {
  int currentTime = MXCurrentTimeInMinutes();

  for (Closing *closing in self.closings.reverseObjectEnumerator) {
    if (closing.trainTime <= currentTime)
      return closing;
  }

  return self.closings.lastObject;
}

- (Closing *)currentClosing {
  int currentTime = MXCurrentTimeInMinutes();
  Closing *nextClosing = self.nextClosing;
  Closing *previousClosing = self.previousClosing;
  return currentTime <= previousClosing.trainTime + PREVIOUS_TRAIN_LAG_TIME && currentTime > previousClosing.trainTime - 1 ? previousClosing : nextClosing;
}

- (int)minutesTillClosing {
  //int nextClosingTime = self.nextClosing.closingTime;
  //int currentTime = MXCurrentTimeInMinutes();
  //
  //int result = nextClosingTime - currentTime;
  //if (result < 0)
  //  result = 24 * 60 + result;
  //
  //return result;
  return [self minutesTillOpening] - CLOSING_TIME;
}

- (int)minutesTillOpening {
  int trainTime = self.nextClosing.trainTime;
  int currentTime = MXCurrentTimeInMinutes();

  int result = trainTime - currentTime;
  if (result < 0)
    result = 24 * 60 + result;

  return result;
}

- (int)minutesSinceOpening {
  int previousTrainTime = self.previousClosing.trainTime;
  int currentTime = MXCurrentTimeInMinutes();

  int result = currentTime - previousTrainTime;
  if (result < 0)
    result = 24 * 60 + result;

  return result;
}

- (BOOL)isClosest {
  return self == model.closestCrossing;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"Crossing(%@, %f, %f, %dn)", name, latitude, longitude, closings.count];
}

- (NSInteger)index {
  return [model.crossings indexOfObject:self];
}

- (void)addClosingWithTime:(NSString *)time direction:(ClosingDirection)direction {
  Closing *closing = [Closing new];
  closing.crossing = self;
  closing.time = time;
  closing.trainTime = [Helper parseStringAsHHMM:time];
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