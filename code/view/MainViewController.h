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
#import "GADBannerViewDelegate.h"

@interface MainViewController : UIViewController <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, GADBannerViewDelegate>
@end
