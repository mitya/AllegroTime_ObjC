//
//  MainViewController.m
//  AllegroTime
//
//  Created by Dmitry Sokurenko on 25.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <CoreLocation/CoreLocation.h>
#import "MainViewController.h"
#import "Models.h"
#import "Helpers.h"

@interface MainViewController ()

@end

NSString *CrossingNameCellID = @"crossing-name-cell";
NSString *CrossingStateCellID = @"crossing-state-cell";
NSString *DefaultWithTriangleCellID = @"default-with-triangle-cell";

const int MainView_CrossingStateSection = 0;
const int MainView_CrossingStateSection_TitleRow = 0;
const int MainView_CrossingStateSection_StateRow = 1;
const int MainView_CrossingActionsSection = 1;

@implementation MainViewController

@synthesize locationState;
@synthesize currentCrossing;
@synthesize locationManager;

#pragma mark - lifecycle

- (id)initWithStyle:(UITableViewStyle)style {
  self = [super initWithStyle:style];
  if (self) {}
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = @"Время Аллегро";

  // set up a location manager

}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  if (CLLocationManager.locationServicesEnabled) {
    [self.locationManager startMonitoringSignificantLocationChanges];
    self.locationState = LocationStateSearching;
  } else {
    self.locationState = LocationStateNotAvailable;
  }
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [self.locationManager stopMonitoringSignificantLocationChanges];
  self.locationState = LocationStateNotAvailable;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - table view stuff

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  switch (section) {
    case MainView_CrossingStateSection:
      return 2;
    case MainView_CrossingActionsSection:
      return 1;
  }
  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell;
  switch (indexPath.section) {
    case MainView_CrossingStateSection:
      switch (indexPath.row) {
        case MainView_CrossingStateSection_TitleRow:
          cell = [tableView dequeueReusableCellWithIdentifier:CrossingNameCellID];
          if (!cell) {
            cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CrossingNameCellID];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
          }
          cell.textLabel.text = @"Переезд";
          cell.detailTextLabel.text = self.currentCrossing.name;
          break;
        case MainView_CrossingStateSection_StateRow:
          cell = [tableView dequeueReusableCellWithIdentifier:CrossingStateCellID];
          if (!cell) {
            cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CrossingStateCellID];
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.textLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
            cell.textLabel.textColor = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
          }
          //cell.textLabel.text = @"Будет закрыт через 3 часа в 17:45";
          //cell.textLabel.text = [NSString stringWithFormat:@"Будет закрыт через %@ часа в %@", self.currentCrossing.timeLeftText, self.currentCrossing.nextTime];
          cell.textLabel.text = [NSString stringWithFormat:@"Будет закрыт в %@", self.currentCrossing.nextTime];
          break;
      }
      break;
    case MainView_CrossingActionsSection:
      switch (indexPath.row) {
        case 0:
          cell = [tableView dequeueReusableCellWithIdentifier:DefaultWithTriangleCellID];
          if (!cell) {
            cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DefaultWithTriangleCellID];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

          }
          cell.textLabel.text = @"Расписание";
          break;
      }
  }

  return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  switch (section) {
    case MainView_CrossingStateSection:
      switch (locationState) {
        case LocationStateNotAvailable: {
          UILabel *label = [Helpers labelForTableViewFooter];
          label.frame = CGRectMake(15, 0, tableView.bounds.size.width - 30, 30);
          label.text = @"Ближайший переезд не определен";
          return label;
        }

        case LocationStateSearching: {
          UIView *header = [[UIView alloc] initWithFrame:CGRectZero];

          UILabel *label = [Helpers labelForTableViewFooter];
          label.frame = CGRectMake(5, 0, tableView.bounds.size.width - 30, 30);
          label.text = @"Поиск ближайшего переезда...";


          UIActivityIndicatorView *spinner = [Helpers spinnerAfterCenteredLabel:label];
          [spinner startAnimating];


          [header addSubview:label];
          [header addSubview:spinner];

          return header;
        }
      }
  }
  return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  switch (section) {
    case MainView_CrossingStateSection:
      switch (locationState) {
        case LocationStateNotAvailable:
        case LocationStateSearching:
          return 30;
      }
  }
  return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
  if (section == MainView_CrossingStateSection && locationState == LocationStateNotAvailable)
    return @"Ближайший переезд не определен";
  return nil;
}


#pragma mark - location management

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
  // * check if the data are fresh enought: abs(newLocation.timestamp.timeIntervalSinceNow) > 60.0
  // * unsubscribe from the further updates if the GPS is used once the precise and recent data are gathered

  self.locationState = LocationStateSet;
  self.currentCrossing = [ModelManager crossingClosestTo:newLocation];
  NSLog(@"%s newLocation.horizontalAccuracy:%f coordinate:%f,%f", _cmd, newLocation.horizontalAccuracy, newLocation.coordinate.latitude, newLocation.coordinate.longitude);
}

#pragma mark - model

- (Crossing *)currentCrossing {
  if (currentCrossing)
    return currentCrossing;
  else
    return [ModelManager currentCrossing];
}

- (void)setCurrentCrossing:(Crossing *)aCrossing {
  if (currentCrossing != aCrossing) {
    currentCrossing = aCrossing;
    [self.tableView reloadData];
  }
}

- (void)setLocationState:(LocationState)aLocationState {
  if (locationState != aLocationState) {
    locationState = aLocationState;
    [self.tableView reloadData];
  }
}

- (CLLocationManager *)locationManager {
  if (!locationManager) {
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    // locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    // locationManager.distanceFilter = 300;
  }
  return locationManager;
}

@end
