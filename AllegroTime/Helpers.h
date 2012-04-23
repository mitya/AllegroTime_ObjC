//
//  Created by Dima on 26.03.12.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

void MXDump(id object);
void MXLog(char const *desc, id object);
void MXLogArray(char const *desc, NSArray *array);
void MXLogString(char const *string);
void MXLogSelector(SEL selector);

// UI
UIColor *MXCellGradientColorFor(UIColor *color);
NSString *MXFormatDate(NSDate *date, NSString *format);

// Logging

NSMutableArray *MXConsoleGet();
void MXConsoleWrite(NSString *string);
void MXConsoleFormat(NSString *format, ...);

// Core extensions

@interface NSString (My)
- (NSString *)format:(id)objects, ...;
- (NSString *)transliterated;
@end

@interface NSArray (My)
- (id)firstObject;
- (id)minimumObject:(double (^)(id))block;
- (id)detectObject:(BOOL (^)(id))predicate;
@end

// General helpers

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
+ (UIColor *)blueTextColor;
@end

typedef enum {
  LocationStateNotAvailable = 1,
  LocationStateSearching = 2,
  LocationStateSet = 3
} LocationState;
