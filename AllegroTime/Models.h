//
//  Created by Dima on 25.03.12.
//


#import <Foundation/Foundation.h>

typedef enum {
  ClosingDirectionToFinland = 1,
  ClosingDirectionToRussia = 2
} ClosingDirection ;

@class Crossing;

@interface Closing : NSObject

@property (strong) NSString *time;
@property (assign) Crossing *crossing;
@property ClosingDirection direction;

- (NSString *)soonestTime;
+ (id)closingWithCrossingName:(NSString *)crossingName time:(NSString *)time direction:(ClosingDirection)direction;
+ (void)seed;

@end

@interface Crossing :NSObject

@property float latitude;
@property float longitude;
@property (strong) NSString *name;
@property (strong) NSMutableArray *closings;

+ (void)seed;
+ (Crossing *)crossingWithName:(NSString *)aName;
+ (Crossing *)getCrossingWithName:(NSString *)name;

@end

@interface ModelManager : NSObject

+ (void)initialize;
+ (Crossing *)currentCrossing;
+ (Crossing *)closestCrossing;
+ (NSString *)geolocationState;

@end


