//
//  CrossingListController.h
//  AllegroTime
//
//  Created by Dmitry Sokurenko on 28.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainViewController;

@interface CrossingListController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) MainViewController *target;
@property (nonatomic, assign) SEL action;
@property (nonatomic, assign) UITableViewCellAccessoryType accessoryType;
@end
