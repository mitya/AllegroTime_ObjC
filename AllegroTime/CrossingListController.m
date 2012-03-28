//
//  CrossingListController.m
//  AllegroTime
//
//  Created by Dmitry Sokurenko on 28.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CrossingListController.h"
#import "Models.h"

@implementation CrossingListController

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return model.crossings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *ClosestCrossingCellID = @"ClosestCrossingCell";
  static NSString *CrossingCellID = @"CrossingCell";
  UITableViewCell *cell;

  Crossing *crossing = [model.crossings objectAtIndex:indexPath.row];

  if (crossing.isClosest) {
    cell = [tableView dequeueReusableCellWithIdentifier:ClosestCrossingCellID];
    if (!cell) {
      cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ClosestCrossingCellID];
      cell.detailTextLabel.text = @"Ближний";
      cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    }
  } else {
    cell = [tableView dequeueReusableCellWithIdentifier:CrossingCellID];
    if (!cell) {
      cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ClosestCrossingCellID];
    }
  }

  cell.textLabel.text = crossing.name;
  cell.accessoryType = crossing == model.selectedCrossing ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];

  int indexOfOldCrossing = [model.crossings indexOfObject:model.selectedCrossing];
  NSIndexPath *oldSelectionIndexPath = [NSIndexPath indexPathForRow:indexOfOldCrossing inSection:0];
  if (indexOfOldCrossing == indexPath.row)
    return;

  model.selectedCrossing = [model.crossings objectAtIndex:indexPath.row];

  UITableViewCell *const oldSelection = [tableView cellForRowAtIndexPath:oldSelectionIndexPath];
  oldSelection.accessoryType = UITableViewCellAccessoryNone;

  UITableViewCell *const newSelection = [tableView cellForRowAtIndexPath:indexPath];
  newSelection.accessoryType = UITableViewCellAccessoryCheckmark;

  [self.navigationController popViewControllerAnimated:YES];
}

@end
