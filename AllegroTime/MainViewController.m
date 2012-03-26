//
//  MainViewController.m
//  AllegroTime
//
//  Created by Dmitry Sokurenko on 25.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "MainViewController.h"

@interface MainViewController ()

@end

NSString const *CrossingNameCellID = @"CrossingNameCell";
NSString const *CrossingStateCellID = @"CrossingStateCell";
NSString const *DefaultWithTriangleCellID = @"DefaultWithTriangleCell";

const int MainViewCrossingStateSection = 0;
const int MainViewCrossingStateSectionTitleRow = 0;
const int MainViewCrossingStateSectionStateRow = 1;
const int MainViewCrossingActionsSection = 1;

@implementation MainViewController

- (id)initWithStyle:(UITableViewStyle)style {
  self = [super initWithStyle:style];
  if (self) {}
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = @"Время Аллегро";
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
        cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CrossingNameCellID];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
      }
      cell.textLabel.text = @"Переезд на Удельной";
    } else if (indexPath.row == MainViewCrossingStateSectionStateRow) {
      cell = [tableView dequeueReusableCellWithIdentifier:CrossingStateCellID];
      if (!cell) {
        cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CrossingStateCellID];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        cell.textLabel.textColor = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
      }
      cell.textLabel.text = @"Будет закрыт через 3 часа в 17:45";
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

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, tableView.bounds.size.width - 30, 25)];
    label.text = @"Определение ближайшего переезда...";
    label.textColor = [UIColor darkGrayColor];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:14];
    label.textAlignment = UITextAlignmentCenter;

    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(tableView.bounds.size.width - spinner.frame.size.width, label.center.y);
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

@end
