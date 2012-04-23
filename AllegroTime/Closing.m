#import <CoreLocation/CoreLocation.h>
#import "Helpers.h"
#import "Models.h"

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