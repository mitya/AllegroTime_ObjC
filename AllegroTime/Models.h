//
//  Created by Dima on 25.03.12.
//


#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef enum {
  ClosingDirectionToFinland = 1,
  ClosingDirectionToRussia = 2
} ClosingDirection ;

typedef enum {
  CrossingStateClear,
  CrossingStateSoon,
  CrossingStateVerySoon,
  CrossingStateClosing,
  CrossingStateClosed,
  CrosingsStateJustOpened
} CrossingState;

@class Crossing;

@interface Closing : NSObject

@property (strong) NSString *time;
@property (assign) Crossing *crossing;
@property ClosingDirection direction;
@property int timeInMinutes;
@property (readonly) int stopTimeInMinutes;

+ (id)closingWithCrossingName:(NSString *)crossingName time:(NSString *)time direction:(ClosingDirection)direction;

@end


@interface Crossing :NSObject

@property float latitude;
@property float longitude;
@property (strong) NSString *name;
@property (strong) NSMutableArray *closings;
@property (readonly) Closing *nextClosing;
@property (readonly) Closing *previousClosing;
@property (readonly) CrossingState state;
@property (readonly) int minutesTillNextClosing;

+ (Crossing *)crossingWithName:(NSString *)name latitude:(double)lat longitude:(double)lng;
+ (Crossing *)getCrossingWithName:(NSString *)name;

@end


@interface ModelManager : NSObject

+ (void)prepare;
+ (NSMutableArray *)crossings;
+ (NSMutableArray *)closings;
+ (Crossing *)currentCrossing;
+ (Crossing *)closestCrossing;
+ (NSString *)geolocationState;
+ (Crossing *)crossingClosestTo:(CLLocation *)location;

@end


