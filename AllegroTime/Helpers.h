//
//  Created by Dima on 26.03.12.
//


#import <Foundation/Foundation.h>

void gDump(id object);

void gLog(char const *desc, id object);
void gLogArray(char const *desc, NSArray *array);
void gLogString(char const *string);
void gLogSelector(SEL selector);


@interface NSString (My)
- (NSString *)format:(id)objects, ...;
@end

@interface NSArray (My)
- (id)firstObject;
@end

@interface Helpers
+ (NSInteger)parseStringAsHHMM:(NSString *)string;
+ (NSInteger)currentTimeInMinutes;

+ (NSComparisonResult)compareInteger:(int)num1 with:(int)num2;
@end
