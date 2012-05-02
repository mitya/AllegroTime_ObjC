#import <CoreLocation/CoreLocation.h>
#import "Helpers.h"
#import "Models.h"

@implementation Closing

#pragma mark - properties

@synthesize time;
@synthesize crossing;
@synthesize direction;
@synthesize trainTime;


- (int)closingTime {
  return trainTime - 10;
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
  return self == self.crossing.currentClosing;
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
  closing.trainTime = [Helper parseStringAsHHMM:time];
  closing.direction = direction;

  [crossing.closings addObject:closing];

  return closing;
}

@end
