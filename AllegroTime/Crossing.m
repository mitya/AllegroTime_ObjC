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
      return [NSString stringWithFormat:@"До закрытия %@", MXFormatMinutesAsText(self.minutesTillNextClosing)];
    case CrossingStateClosed:
      return @"Переезд закрыт";
    case CrosingsStateJustOpened:
      return @"Только что открыли";
    default:
      return nil;
  }
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