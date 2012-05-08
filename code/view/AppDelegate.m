//
//  AppDelegate.m
//  AllegroTime
//
//  Created by Dmitry Sokurenko on 25.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "CrossingMapController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize locationManager;
@synthesize perMinuteTimer;
@synthesize mapController;
@synthesize navigationController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  model = [ModelManager alloc];
  model = [model init];
  app = self;

  self.navigationController = [UINavigationController.alloc initWithRootViewController:[MainViewController.alloc initWithNibName:@"MainView" bundle:nil]];
  self.navigationController.delegate = self;

  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.window.backgroundColor = [UIColor whiteColor];
  self.window.rootViewController = self.navigationController;

  [self.window makeKeyAndVisible];
  
  perMinuteTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(timerTicked) userInfo:nil repeats:YES];
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
  [self triggerModelUpdateFor:self.navigationController.visibleViewController];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
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
  MXWriteToConsole(@"didUpdateToLocation acc=%.f dist=%.f %@", newLocation.horizontalAccuracy, [newLocation distanceFromLocation:oldLocation], model.closestCrossing.name);

  Crossing *const newClosestCrossing = [model crossingClosestTo:newLocation];
  if (newClosestCrossing != model.closestCrossing) {
    model.closestCrossing = newClosestCrossing;
    [[NSNotificationCenter defaultCenter] postNotificationName:NXClosestCrossingChanged object:model.closestCrossing];
  }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
  MXWriteToConsole(@"locationManager:didFailWithError: %@", error);

  model.closestCrossing = nil;
  [[NSNotificationCenter defaultCenter] postNotificationName:NXClosestCrossingChanged object:model.closestCrossing];
}

#pragma mark - handlers

- (void)navigationController:(UINavigationController *)navController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
  [self.navigationController setToolbarHidden:(viewController.toolbarItems.count == 0) animated:animated];

  if (animated)
    [self triggerModelUpdateFor:viewController];
}

- (void)timerTicked {
  [self triggerModelUpdateFor:self.navigationController.visibleViewController];
}

- (void)triggerModelUpdateFor:(UIViewController *)controller {
  if ([controller respondsToSelector:@selector(modelUpdated)]) {
    [controller performSelector:@selector(modelUpdated)];
  }
}

#pragma mark - properties

- (CrossingMapController *)mapController {
  if (!mapController)
    mapController = [[CrossingMapController alloc] init];
  return mapController;
}

@end
