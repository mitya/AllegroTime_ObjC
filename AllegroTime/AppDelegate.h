//
//  AppDelegate.h
//  AllegroTime
//
//  Created by Dmitry Sokurenko on 25.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class CrossingMapController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, strong) NSTimer *perMinuteTimer;
@property (strong, nonatomic) CrossingMapController *mapController;
@end
