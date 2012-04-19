//
//  Created by Dima on 25.03.12.
//


#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

/******************************************************************************/

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

typedef enum {
  StateColorGreen,
  StateColorYellow,
  StateColorRed
} StateColor;

@class Crossing;

/******************************************************************************/

@interface Closing : NSObject

@property (strong) NSString *time;
@property (assign) Crossing *crossing;
@property ClosingDirection direction;
@property int timeInMinutes;
@property (readonly) int stopTimeInMinutes;
@property (readonly) BOOL toRussia;
@property (readonly) int trainNumber;

+ (id)closingWithCrossingName:(NSString *)crossingName time:(NSString *)time direction:(ClosingDirection)direction;

@end

/******************************************************************************/

@interface Crossing : NSObject <MKAnnotation>

@property (nonatomic) float latitude;
@property (nonatomic) float longitude;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *closings;
@property (nonatomic, readonly) StateColor stateColor;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) Closing *nextClosing;
@property (nonatomic, readonly) Closing *previousClosing;
@property (nonatomic, readonly) CrossingState state;
@property (nonatomic, readonly) int minutesTillNextClosing;
@property (nonatomic, readonly) BOOL isClosest;

@property (nonatomic, assign) int distance;

+ (Crossing *)crossingWithName:(NSString *)name latitude:(double)lat longitude:(double)lng;
+ (Crossing *)getCrossingWithName:(NSString *)name;

- (void)addClosingWithTime:(NSString *)time direction:(ClosingDirection)direction;
@end

/******************************************************************************/

@interface ModelManager : NSObject

@property (nonatomic, strong) NSMutableArray *crossings;
@property (nonatomic, strong) NSMutableArray * closings;
@property (nonatomic, strong) Crossing* closestCrossing;
@property (nonatomic, strong) Crossing* selectedCrossing;
@property (nonatomic, readonly) Crossing* currentCrossing;
@property (nonatomic, readonly) Crossing* defaultCrossing;
@property (nonatomic, strong) CLLocationManager *locationManager;

- (Crossing *)crossingClosestTo:(CLLocation *)location;

+ (void)prepare;

//+ (NSMutableArray *)crossings;
//+ (NSMutableArray *)closings;
//+ (Crossing *)currentCrossing;
//+ (Crossing *)closestCrossing;
//+ (void)setSelectedCrossing:(Crossing *)crossing;
//+ (NSString *)geolocationState;

@end

ModelManager *model;
