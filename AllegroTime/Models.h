//
//  Created by Dima on 25.03.12.
//


#import <Foundation/Foundation.h>

typedef enum ClosingDirection {
  ClosingDirectionToFinland = 1,
  ClosingDirectionToRussia = 2
} ClosingDirection ;

@class Crossing;

@interface Closing : NSObject
@property (strong) NSString *time;
@property (strong) Crossing *crossing;
@property ClosingDirection direction;
@end

@interface Crossing :NSObject
@property (strong) NSString *name;
@property float latitude;
@property float longitude;
@end
