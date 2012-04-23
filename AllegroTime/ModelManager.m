//
//  Created by Dima on 25.03.12.
//

#import <CoreLocation/CoreLocation.h>
#import "Helpers.h"
#import "Models.h"

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
