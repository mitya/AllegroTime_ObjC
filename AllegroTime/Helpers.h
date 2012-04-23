//
//  Created by Dima on 26.03.12.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

void gDump(id object);

void gLog(char const *desc, id object);

void gLogArray(char const *desc, NSArray *array);

void gLogString(char const *string);

void gLogSelector(SEL selector);


@interface NSString (My)
- (NSString *)format:(id)objects, ...;

- (NSString *)transliterated;
@end

@interface NSArray (My)
- (id)firstObject;

- (id)minimumObject:(double (^)(id))block;

- (id)detectObject:(BOOL (^)(id))predicate;


@end

@interface Helper
+ (NSInteger)parseStringAsHHMM:(NSString *)string;

+ (NSInteger)currentTimeInMinutes;

+ (NSComparisonResult)compareInteger:(int)num1 with:(int)num2;

+ (UILabel *)labelForTableViewFooter;

+ (float)tableViewCellWidth;

+ (UIActivityIndicatorView *)spinnerAfterCenteredLabel:(UILabel *)label;

+ (NSString *)formatTimeInMunutesAsHHMM:(int)minutesSinceMidnight;

+ (UIColor *)greenColor;

+ (UIColor *)yellowColor;

+ (int)roundToFive:(int)value;


+ (NSTimeInterval)timeTillFullMinute;

+ (NSDate *)nextFullMinuteDate;

+ (UIColor *)cellGradientColorFor:(UIColor *)color;

+ (UIColor *)blueTextColor;

@end

typedef enum {
  LocationStateNotAvailable = 1,
  LocationStateSearching = 2,
  LocationStateSet = 3
} LocationState;