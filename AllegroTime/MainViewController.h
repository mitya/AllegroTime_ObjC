//
//  MainViewController.h
//  AllegroTime
//
//  Created by Dmitry Sokurenko on 25.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Helpers.h"
#import "Models.h"

@interface MainViewController : UITableViewController <CLLocationManagerDelegate>
@property (nonatomic, assign) LocationState locationState;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSTimer *timer;

@end
