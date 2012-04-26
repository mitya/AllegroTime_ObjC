//
//  AppDelegate.m
//  AllegroTime
//
//  Created by Dmitry Sokurenko on 25.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize locationManager;
@synthesize perMinuteTimer;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [ModelManager prepare];

  UINavigationController *navigationController = [UINavigationController.alloc initWithRootViewController:[MainViewController.alloc initWithNibName:@"MainView" bundle:nil]];  

  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.window.backgroundColor = [UIColor whiteColor];
  self.window.rootViewController = navigationController;

  [self.window makeKeyAndVisible];
  
  perMinuteTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(minuteElapsed) userInfo:nil repeats:YES];
  perMinuteTimer.fireDate = [Helper nextFullMinuteDate];

  return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  if (CLLocationManager.locationServicesEnabled) {
    [self.locationManager startUpdatingLocation];
  }
}

- (void)applicationWillResignActive:(UIApplication *)application {
  [self.locationManager stopUpdatingLocation];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  NSLog(@"%s ", __func__);
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  NSLog(@"%s ", __func__);
}

- (void)applicationWillTerminate:(UIApplication *)application {
  NSLog(@"%s ", __func__);
}

#pragma mark - Location Tracking

- (CLLocationManager *)locationManager {
  if (!locationManager) {
    locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    locationManager.distanceFilter = 100;
  }
  return locationManager;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
  MXWriteToConsole(@"newLocation acc=%.f dist=%.f %@", newLocation.horizontalAccuracy, [newLocation distanceFromLocation:oldLocation], model.closestCrossing.name);

  model.closestCrossing = [model crossingClosestTo:newLocation];
  [[NSNotificationCenter defaultCenter] postNotificationName:NXClosestCrossingChanged object:model.closestCrossing];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
  MXWriteToConsole(@"locationFailed %@", error);

  model.closestCrossing = nil;
  [[NSNotificationCenter defaultCenter] postNotificationName:NXClosestCrossingChanged object:model.closestCrossing];
}

#pragma mark - handlers

- (void)minuteElapsed {
  [[NSNotificationCenter defaultCenter] postNotificationName:NXModelUpdated object:nil];
}

@end
