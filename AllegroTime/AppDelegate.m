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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [ModelManager prepare];

  UINavigationController *navigationController = [UINavigationController.alloc initWithRootViewController:[MainViewController.alloc initWithNibName:@"MainView" bundle:nil]];  

  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.window.backgroundColor = [UIColor whiteColor];
  self.window.rootViewController = navigationController;

  [self.window makeKeyAndVisible];
  
  // NSLog(@"%i %i %i", CLLocationManager.locationServicesEnabled, [CLLocationManager significantLocationChangeMonitoringAvailable], [CLLocationManager authorizationStatus]);

  return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  if (CLLocationManager.locationServicesEnabled) {
    [self.locationManager startUpdatingLocation];
    //if ([CLLocationManager significantLocationChangeMonitoringAvailable]) [self.locationManager startMonitoringSignificantLocationChanges];
    //else [self.locationManager startUpdatingLocation];
  }
}

- (void)applicationWillResignActive:(UIApplication *)application {
  NSLog(@"%s", __func__);
  [self.locationManager stopUpdatingLocation];
  [self.locationManager stopMonitoringSignificantLocationChanges];
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

@end
