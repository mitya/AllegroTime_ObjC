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
  return [NSString stringWithFormat:@"Crossing(%@, %f, %f, %dn)", name.transliterated, latitude, longitude, closings.count];
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

//- (CLLocationManager *)locationManager {
//  if (!locationManager) {
//    locationManager = [CLLocationManager new];
//    //    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
//    //    locationManager.distanceFilter = 300;
//  }
//  return locationManager;
//}


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
  [self loadFile];
  return self;
}

- (void) loadFile {
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
    [crossing addClosingWithTime:[components objectAtIndex:lastDatumIndex + 1] direction: ClosingDirectionToFinland];
    [crossing addClosingWithTime:[components objectAtIndex:lastDatumIndex + 2] direction: ClosingDirectionToRussia];
    [crossing addClosingWithTime:[components objectAtIndex:lastDatumIndex + 3] direction: ClosingDirectionToFinland];
    [crossing addClosingWithTime:[components objectAtIndex:lastDatumIndex + 4] direction: ClosingDirectionToRussia];
    [crossing addClosingWithTime:[components objectAtIndex:lastDatumIndex + 5] direction: ClosingDirectionToFinland];
    [crossing addClosingWithTime:[components objectAtIndex:lastDatumIndex + 6] direction: ClosingDirectionToRussia];
    [crossing addClosingWithTime:[components objectAtIndex:lastDatumIndex + 7] direction: ClosingDirectionToFinland];
    [crossing addClosingWithTime:[components objectAtIndex:lastDatumIndex + 8] direction: ClosingDirectionToRussia];

    [crossings addObject:crossing];
  }

  closings = [NSMutableArray arrayWithCapacity:crossings.count * 8];
  for (Crossing *crossing in crossings) {
    [closings addObjectsFromArray:crossing.closings];
  }
}

//- (void) loadPredefinedData {
//  // [Crossing crossingWithName:@"Солнечное" latitude:60.15951 longitude:29.937442], // не существует
//  // [Crossing crossingWithName:@"Ушково" latitude:60.221009 longitude:29.623949],  // не существует
//  crossings = [NSMutableArray arrayWithObjects:
//      [Crossing crossingWithName:@"Удельная" latitude:60.017533 longitude:30.313379],
//      [Crossing crossingWithName:@"Поклонногорская" latitude:60.025533 longitude:30.309113],
//      [Crossing crossingWithName:@"Озерки - Шувалово" latitude:60.042087 longitude:30.300095],
//      [Crossing crossingWithName:@"Дорога на Каменку" latitude:60.070331 longitude:30.275285],
//      [Crossing crossingWithName:@"Парголово" latitude:60.079674 longitude:30.260536],
//      [Crossing crossingWithName:@"Песочная" latitude:60.118323 longitude:30.147631],
//      [Crossing crossingWithName:@"Дибуны" latitude:60.121706 longitude:30.130231],
//      [Crossing crossingWithName:@"Белоостровское шоссе" latitude:60.146049 longitude:30.006676],
//      [Crossing crossingWithName:@"Белоостров" latitude:60.134852 longitude:30.063732],
//      [Crossing crossingWithName:@"Репино" latitude:60.174512 longitude:29.860736],
//      [Crossing crossingWithName:@"Комарово" latitude:60.186113 longitude:29.800448],
//      [Crossing crossingWithName:@"Рощинское шоссе" latitude:60.227382 longitude:29.612833],
//      [Crossing crossingWithName:@"Рощино" latitude:60.251283 longitude:29.572106],
//      [Crossing crossingWithName:@"Горьковское" latitude:60.294546 longitude:29.493518],
//      nil];
//
//
//  // http://ozd.rzd.ru/static/public/ozd?STRUCTURE_ID=4735
//  closings = [NSMutableArray arrayWithObjects:
//      [Closing closingWithCrossingName:@"Удельная" time:@"06:46" direction:ClosingDirectionToFinland],
//      [Closing closingWithCrossingName:@"Удельная" time:@"11:32" direction:ClosingDirectionToFinland],
//      [Closing closingWithCrossingName:@"Удельная" time:@"15:32" direction:ClosingDirectionToFinland],
//      [Closing closingWithCrossingName:@"Удельная" time:@"20:32" direction:ClosingDirectionToFinland],
//      [Closing closingWithCrossingName:@"Удельная" time:@"10:36" direction:ClosingDirectionToRussia],
//      [Closing closingWithCrossingName:@"Удельная" time:@"14:21" direction:ClosingDirectionToRussia],
//      [Closing closingWithCrossingName:@"Удельная" time:@"19:21" direction:ClosingDirectionToRussia],
//      [Closing closingWithCrossingName:@"Удельная" time:@"23:21" direction:ClosingDirectionToRussia],
//
//      [Closing closingWithCrossingName:@"Поклонногорская" time:@"06:47" direction:ClosingDirectionToFinland],
//      [Closing closingWithCrossingName:@"Поклонногорская" time:@"11:33" direction:ClosingDirectionToFinland],
//      [Closing closingWithCrossingName:@"Поклонногорская" time:@"15:33" direction:ClosingDirectionToFinland],
//      [Closing closingWithCrossingName:@"Поклонногорская" time:@"20:33" direction:ClosingDirectionToFinland],
//      [Closing closingWithCrossingName:@"Поклонногорская" time:@"10:35" direction:ClosingDirectionToRussia],
//      [Closing closingWithCrossingName:@"Поклонногорская" time:@"14:20" direction:ClosingDirectionToRussia],
//      [Closing closingWithCrossingName:@"Поклонногорская" time:@"19:20" direction:ClosingDirectionToRussia],
//      [Closing closingWithCrossingName:@"Поклонногорская" time:@"23:20" direction:ClosingDirectionToRussia],
//
//      [Closing closingWithCrossingName:@"Озерки - Шувалово" time:@"06:50" direction:ClosingDirectionToFinland],
//      [Closing closingWithCrossingName:@"Озерки - Шувалово" time:@"11:34" direction:ClosingDirectionToFinland],
//      [Closing closingWithCrossingName:@"Озерки - Шувалово" time:@"15:34" direction:ClosingDirectionToFinland],
//      [Closing closingWithCrossingName:@"Озерки - Шувалово" time:@"20:34" direction:ClosingDirectionToFinland],
//      [Closing closingWithCrossingName:@"Озерки - Шувалово" time:@"10:30" direction:ClosingDirectionToRussia],
//      [Closing closingWithCrossingName:@"Озерки - Шувалово" time:@"14:19" direction:ClosingDirectionToRussia],
//      [Closing closingWithCrossingName:@"Озерки - Шувалово" time:@"19:19" direction:ClosingDirectionToRussia],
//      [Closing closingWithCrossingName:@"Озерки - Шувалово" time:@"23:19" direction:ClosingDirectionToRussia],
//
//      [Closing closingWithCrossingName:@"Дорога на Каменку" time:@"06:51" direction:ClosingDirectionToFinland],
//      [Closing closingWithCrossingName:@"Дорога на Каменку" time:@"11:35" direction:ClosingDirectionToFinland],
//      [Closing closingWithCrossingName:@"Дорога на Каменку" time:@"15:35" direction:ClosingDirectionToFinland],
//      [Closing closingWithCrossingName:@"Дорога на Каменку" time:@"20:35" direction:ClosingDirectionToFinland],
//      [Closing closingWithCrossingName:@"Дорога на Каменку" time:@"10:27" direction:ClosingDirectionToRussia],
//      [Closing closingWithCrossingName:@"Дорога на Каменку" time:@"14:15" direction:ClosingDirectionToRussia],
//      [Closing closingWithCrossingName:@"Дорога на Каменку" time:@"19:15" direction:ClosingDirectionToRussia],
//      [Closing closingWithCrossingName:@"Дорога на Каменку" time:@"23:15" direction:ClosingDirectionToRussia],
//
//      [Closing closingWithCrossingName:@"Парголово" time:@"06:52" direction:ClosingDirectionToFinland], // extrapolated
//      [Closing closingWithCrossingName:@"Парголово" time:@"11:36" direction:ClosingDirectionToFinland],
//      [Closing closingWithCrossingName:@"Парголово" time:@"15:36" direction:ClosingDirectionToFinland],
//      [Closing closingWithCrossingName:@"Парголово" time:@"20:36" direction:ClosingDirectionToFinland],
//      [Closing closingWithCrossingName:@"Парголово" time:@"10:26" direction:ClosingDirectionToRussia],
//      [Closing closingWithCrossingName:@"Парголово" time:@"14:14" direction:ClosingDirectionToRussia],
//      [Closing closingWithCrossingName:@"Парголово" time:@"19:14" direction:ClosingDirectionToRussia],
//      [Closing closingWithCrossingName:@"Парголово" time:@"23:14" direction:ClosingDirectionToRussia],
//
//      [Closing closingWithCrossingName:@"Песочная" time:@"06:56" direction:ClosingDirectionToFinland],
//      [Closing closingWithCrossingName:@"Песочная" time:@"11:40" direction:ClosingDirectionToFinland],
//      [Closing closingWithCrossingName:@"Песочная" time:@"15:40" direction:ClosingDirectionToFinland],
//      [Closing closingWithCrossingName:@"Песочная" time:@"20:40" direction:ClosingDirectionToFinland],
//      [Closing closingWithCrossingName:@"Песочная" time:@"10:21" direction:ClosingDirectionToRussia],
//      [Closing closingWithCrossingName:@"Песочная" time:@"14:09" direction:ClosingDirectionToRussia],
//      [Closing closingWithCrossingName:@"Песочная" time:@"19:09" direction:ClosingDirectionToRussia],
//      [Closing closingWithCrossingName:@"Песочная" time:@"23:09" direction:ClosingDirectionToRussia],
//
//      [Closing closingWithCrossingName:@"Дибуны" time:@"06:56" direction:ClosingDirectionToFinland],
//      [Closing closingWithCrossingName:@"Дибуны" time:@"11:40" direction:ClosingDirectionToFinland],
//      [Closing closingWithCrossingName:@"Дибуны" time:@"15:40" direction:ClosingDirectionToFinland],
//      [Closing closingWithCrossingName:@"Дибуны" time:@"20:40" direction:ClosingDirectionToFinland],
//      [Closing closingWithCrossingName:@"Дибуны" time:@"10:21" direction:ClosingDirectionToRussia],
//      [Closing closingWithCrossingName:@"Дибуны" time:@"14:09" direction:ClosingDirectionToRussia],
//      [Closing closingWithCrossingName:@"Дибуны" time:@"19:09" direction:ClosingDirectionToRussia],
//      [Closing closingWithCrossingName:@"Дибуны" time:@"23:09" direction:ClosingDirectionToRussia],
//
//      [Closing closingWithCrossingName:@"Белоостровское шоссе" time:@"06:58" direction:ClosingDirectionToFinland], // extrapolated
//      [Closing closingWithCrossingName:@"Белоостровское шоссе" time:@"11:42" direction:ClosingDirectionToFinland],
//      [Closing closingWithCrossingName:@"Белоостровское шоссе" time:@"15:42" direction:ClosingDirectionToFinland],
//      [Closing closingWithCrossingName:@"Белоостровское шоссе" time:@"20:42" direction:ClosingDirectionToFinland],
//      [Closing closingWithCrossingName:@"Белоостровское шоссе" time:@"10:19" direction:ClosingDirectionToRussia],
//      [Closing closingWithCrossingName:@"Белоостровское шоссе" time:@"14:07" direction:ClosingDirectionToRussia],
//      [Closing closingWithCrossingName:@"Белоостровское шоссе" time:@"19:07" direction:ClosingDirectionToRussia],
//      [Closing closingWithCrossingName:@"Белоостровское шоссе" time:@"23:07" direction:ClosingDirectionToRussia],
//
//      nil];
//
//  for (Crossing *crossing in crossings) {
//    [crossing.closings sortUsingComparator:^NSComparisonResult(Closing *obj1, Closing *obj2) {
//      return [Helper compareInteger:obj1.timeInMinutes with:obj2.timeInMinutes];
//    }];
//  }
//}

@end
