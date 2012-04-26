//
//  Created by Dima on 25.03.12.
//


#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "Helpers.h"
#import "AppDelegate.h"

/******************************************************************************/

typedef enum {
  ClosingDirectionToFinland = 1,
  ClosingDirectionToRussia = 2
} ClosingDirection;

typedef enum {
  CrossingStateClear,
  CrossingStateSoon,
  CrossingStateVerySoon,
  CrossingStateClosing,
  CrossingStateClosed,
  CrosingsStateJustOpened
} CrossingState;

typedef enum {
  StateColorGreen,
  StateColorYellow,
  StateColorRed
} StateColor;

@class Crossing;

#define PREVIOUS_TRAIN_LAG_TIME 5
#define CLOSING_TIME 10

/******************************************************************************/

@interface Closing : NSObject

@property (nonatomic, strong) NSString *time;
@property (nonatomic, assign) Crossing *crossing;
@property (nonatomic) ClosingDirection direction;
@property (nonatomic) int trainTime;
@property (nonatomic, readonly) int closingTime;
@property (nonatomic, readonly) BOOL toRussia;
@property (nonatomic, readonly) int trainNumber;
@property (nonatomic, readonly) BOOL isClosest;
@property (nonatomic, readonly) CrossingState state;
@property (nonatomic, readonly) UIColor *color;

+ (id)closingWithCrossingName:(NSString *)crossingName time:(NSString *)time direction:(ClosingDirection)direction;

@end

/******************************************************************************/

@interface Crossing : NSObject <MKAnnotation>

@property (nonatomic) float latitude;
@property (nonatomic) float longitude;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *closings;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) Closing *nextClosing;
@property (nonatomic, readonly) Closing *previousClosing;
@property (nonatomic, readonly) Closing *currentClosing;
@property (nonatomic, readonly) CrossingState state;
@property (nonatomic, readonly) UIColor *color;
@property (nonatomic, readonly) int minutesTillClosing;
@property (nonatomic, readonly) int minutesTillOpening;
@property (nonatomic, readonly) int minutesSinceOpening;
@property (nonatomic, readonly) BOOL isClosest;
@property (nonatomic, assign) int distance;
@property (nonatomic, readonly) NSInteger index;

- (void)addClosingWithTime:(NSString *)time direction:(ClosingDirection)direction;

+ (Crossing *)crossingWithName:(NSString *)name latitude:(double)lat longitude:(double)lng;
+ (Crossing *)getCrossingWithName:(NSString *)name;
@end

/******************************************************************************/

@interface ModelManager : NSObject

@property (nonatomic, strong) NSMutableArray *crossings;
@property (nonatomic, strong) NSMutableArray *closings;
@property (nonatomic, strong) Crossing *closestCrossing;
@property (nonatomic, strong) Crossing *selectedCrossing;
@property (nonatomic, strong) Crossing *currentCrossing;
@property (nonatomic, readonly, strong) Crossing *defaultCrossing;

- (Crossing *)crossingClosestTo:(CLLocation *)location;

@end

ModelManager *model;
AppDelegate *app;
