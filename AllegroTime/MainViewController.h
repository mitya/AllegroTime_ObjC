//
//  MainViewController.h
//  AllegroTime
//
//  Created by Dmitry Sokurenko on 25.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Crossing;

@interface MainViewController : UITableViewController
- (Crossing *)currentCrossing;
@end
