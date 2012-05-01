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

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSTimer *perMinuteTimer;
@property (strong, nonatomic) CrossingMapController *mapController;
@property (strong, nonatomic) UINavigationController *navigationController;
@end
