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
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize locationManager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [ModelManager prepare];

  UINavigationController *navigationController = [UINavigationController.alloc initWithRootViewController:[MainViewController.alloc initWithNibName:@"MainView" bundle:nil]];  

  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.window.backgroundColor = [UIColor whiteColor];
  self.window.rootViewController = navigationController;

  [self.window makeKeyAndVisible];
  
//  NSLog(@"%i %i %i", CLLocationManager.locationServicesEnabled, [CLLocationManager significantLocationChangeMonitoringAvailable], [CLLocationManager authorizationStatus]);

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
  if (CLLocationManager.locationServicesEnabled) {
    [self.locationManager stopUpdatingLocation];
    //if ([CLLocationManager significantLocationChangeMonitoringAvailable]) [self.locationManager stopMonitoringSignificantLocationChanges];
    //else [self.locationManager stopUpdatingLocation];
  }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  NSLog(@"%s ", __func__);
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  NSLog(@"%s ", __func__);
}

- (void)applicationWillTerminate:(UIApplication *)application {
  NSLog(@"%s ", __func__);
  [self saveContext];
}

- (void)saveContext {
  NSError *error = nil;
  NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
  if (managedObjectContext != nil) {
    if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
      // Replace this implementation with code to handle the error appropriately.
      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
    }
  }
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
  // * check if the data are fresh enought: abs(newLocation.timestamp.timeIntervalSinceNow) > 60.0
  // * unsubscribe from the further updates if the GPS is used once the precise and recent data are gathered
  MXConsoleFormat(@"newLocation acc %.1f dist %.1f %@", newLocation.horizontalAccuracy, [newLocation distanceFromLocation:oldLocation], model.closestCrossing.name);

  model.closestCrossing = [model crossingClosestTo:newLocation];
  [[NSNotificationCenter defaultCenter] postNotificationName:NXClosestCrossingChanged object:model.closestCrossing];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
  MXConsoleFormat(@"locationFailed %@", error);

  model.closestCrossing = nil;
  [[NSNotificationCenter defaultCenter] postNotificationName:NXClosestCrossingChanged object:model.closestCrossing];
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
  if (__managedObjectContext != nil) {
    return __managedObjectContext;
  }

  NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
  if (coordinator != nil) {
    __managedObjectContext = [[NSManagedObjectContext alloc] init];
    [__managedObjectContext setPersistentStoreCoordinator:coordinator];
  }
  return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
  if (__managedObjectModel != nil) {
    return __managedObjectModel;
  }
  NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"AllegroTime" withExtension:@"momd"];
  __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
  return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
  if (__persistentStoreCoordinator != nil) {
    return __persistentStoreCoordinator;
  }

  NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"AllegroTime.sqlite"];

  NSError *error = nil;
  __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
  if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
    /*
    Replace this implementation with code to handle the error appropriately.

    abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

    Typical reasons for an error here include:
    * The persistent store is not accessible;
    * The schema for the persistent store is incompatible with current managed object model.
    Check the error message to determine what the actual problem was.


    If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.

    If you encounter schema incompatibility errors during development, you can reduce their frequency by:
    * Simply deleting the existing store:
    [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]

    * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
    [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];

    Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.

    */
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    abort();
  }

  return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
  return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
