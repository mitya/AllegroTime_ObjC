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
NSString *T(const char *string);
NSString *TF(const char *format, ...);
NSString *MXPluralizeRussiaWord(int number, NSString *word1, NSString *word2, NSString *word5);
NSString *MXFormatMinutesAsText(int totalMinutes);
NSString *MXFormatMinutesAsTextWithZero(int totalMinutes, NSString *formatString, NSString *zeroString);

// UI
UIColor *MXCellGradientColorFor(UIColor *color);
NSString *MXFormatDate(NSDate *date, NSString *format);
NSString *MXTimestampString();
int MXCurrentTimeInMinutes();
BOOL MXAutorotationPolicy(UIInterfaceOrientation interfaceOrientation);
void MXSetGradientForCell(UITableViewCell *cell, UIColor *color);
NSString *MXNameForColor(UIColor *color);
UILabel *MXConfigureLabelLikeInTableViewFooter(UILabel *label);

UIImage *MXImageFromFile(NSString *filename);

// Logging

NSMutableArray *MXGetConsole();
void MXWriteToConsole(NSString *format, ...);

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
+ (NSComparisonResult)compareInteger:(int)num1 with:(int)num2;
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

// Constants

NSString *const NXClosestCrossingChanged;
NSString *const NXLogConsoleUpdated;
NSString *const NXLogConsoleFlushed;
NSString *const NXModelUpdated;
NSString *const MXDefaultCellID;