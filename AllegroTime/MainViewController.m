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

NSString *CrossingNameCellID = @"CrossingNameCell";
NSString *CrossingStateCellID = @"CrossingStateCell";
NSString *DefaultWithTriangleCellID = @"DefaultWithTriangleCell";

const int MainViewCrossingStateSection = 0;
const int MainViewCrossingStateSectionTitleRow = 0;
const int MainViewCrossingStateSectionStateRow = 1;
const int MainViewCrossingActionsSection = 1;

@implementation MainViewController {
  CLLocationManager *locationManager;
}

- (id)initWithStyle:(UITableViewStyle)style {
  self = [super initWithStyle:style];
  if (self) {}
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = @"Время Аллегро";

  locationManager = [[CLLocationManager alloc] init];
  locationManager.delegate = self;
  locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
  [locationManager startUpdatingLocation];
  NSLog(@"locationManager.locationServicesEnabled: %c", CLLocationManager.locationServicesEnabled);

}

- (void)viewDidUnload {
  [super viewDidUnload];
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
    case MainViewCrossingStateSection:
      return 2;
      break;
    case MainViewCrossingActionsSection:
      return 1;
      break;
    default:
      return 0;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell;
  if (indexPath.section == MainViewCrossingStateSection) {
    if (indexPath.row == MainViewCrossingStateSectionTitleRow) {
      cell = [tableView dequeueReusableCellWithIdentifier:CrossingNameCellID];
      if (!cell) {
        cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CrossingNameCellID];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      }
      cell.textLabel.text = @"Переезд";
      cell.detailTextLabel.text = self.currentCrossing.name;

    } else if (indexPath.row == MainViewCrossingStateSectionStateRow) {
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
      cell.textLabel.text = [NSString stringWithFormat:@"Переезд будет закрыт в %@", self.currentCrossing.nextTime];
    }
  } else if (indexPath.section == MainViewCrossingActionsSection) {
    if (indexPath.row == 0) {
      cell = [tableView dequeueReusableCellWithIdentifier:DefaultWithTriangleCellID];
      if (!cell) {
        cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DefaultWithTriangleCellID];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      }
      cell.textLabel.text = @"Расписание";

    }
  }

  return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  if (section == MainViewCrossingStateSection) {
    UIView *header = [[UIView alloc] initWithFrame:CGRectZero];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, tableView.bounds.size.width - 30, 25)];
    label.text = @"Поиск ближайшего переезда...";
    label.textColor = [UIColor darkGrayColor];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:14];
    label.textAlignment = UITextAlignmentCenter;

    CGSize labelSize = [label.text sizeWithFont:label.font];
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(labelSize.width + (label.frame.size.width - labelSize.width) / 2 + spinner.frame.size.width, label.center.y);
    [spinner startAnimating];

    [header addSubview:label];
    [header addSubview:spinner];

    return header;
  } else {
    return nil;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  if (section == MainViewCrossingStateSection) {
    return 25;
  } else {
    return 0;
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - location management

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
  //NSLog(@"oldLocation: %@", oldLocation);
  //NSLog(@"newLocation: %@", newLocation);
}

#pragma mark - model

- (Crossing *)currentCrossing {
  return [ModelManager currentCrossing];
}

@end
