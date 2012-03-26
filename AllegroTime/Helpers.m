//
//  Created by Dima on 26.03.12.
//


#import "Helpers.h"

void gLogArray(char const *desc, NSArray *array) {
  NSLog(@"%s array dump:", desc);
  for (int i = 0; i < array.count; i++) {
    NSLog(@"  %2i: %@", i, [array objectAtIndex:i]);
  }
}

void gLogString(char const *string) {
  NSLog(@"%s", string);
}

void gLogSelector(SEL selector) {
  NSLog(@">> %s", (char *) selector);
}

void gLog(char const *desc, id object) {
  if ([object isKindOfClass:NSArray.class]) {
    gLogArray(desc, object);
  } else {
    NSLog(@"%s = %@", desc, object);
  }
}

void gDump(id object) {
  NSLog(@"%@", object);
}

@implementation NSString (My)
- (NSString *)format:(id)objects, ... {
  return [NSString stringWithFormat:self, objects];
}
@end


@implementation NSArray (My)

- (id)firstObject {
  return [self objectAtIndex:0];
}

@end


@implementation Helpers

+ (NSInteger)parseStringAsHHMM:(NSString *)string {
  NSArray *components = [string componentsSeparatedByString:@":"];
  NSInteger hours = [[components objectAtIndex:0] integerValue];
  NSInteger minutes = [[components objectAtIndex:1] integerValue];
  return hours * 60 + minutes;
}

+ (NSInteger)currentTimeInMinutes {
  NSDate *now = [NSDate date];
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDateComponents *nowParts = [calendar components:NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:now];

  NSInteger hours = nowParts.hour;
  NSInteger minutes = nowParts.minute;
  return hours * 60 + minutes;
}

+ (NSString *)formatDate:(NSDate *)date withFormat:(NSString *)format {
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:format];
  return [dateFormatter stringFromDate:date];
}

+ (NSComparisonResult)compareInteger:(int)num1 with:(int)num2 {
  if (num1 < num2)
    return -1;
  else if (num1 > num2)
    return 1;
  else
    return 0;

}
@end