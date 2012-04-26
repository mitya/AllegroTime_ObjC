//
//  CrossingMapController.h
//  AllegroTime
//
//  Created by Dmitry Sokurenko on 19.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Models.h"

@interface CrossingMapController : UIViewController <MKMapViewDelegate>
- (void)showCrossing:(Crossing *)aCrossing;
@end
