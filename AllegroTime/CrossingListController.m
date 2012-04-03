//
//  CrossingListController.m
//  AllegroTime
//
//  Created by Dmitry Sokurenko on 28.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CrossingListController.h"
#import "Models.h"
#import "MainViewController.h"

@implementation CrossingListController
@synthesize target;
@synthesize action;
@synthesize accessoryType;


- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = @"Переезды";
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return model.crossings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CrossingCellID = @"CrossingCell";
  UITableViewCell *cell;

  Crossing *crossing = [model.crossings objectAtIndex:indexPath.row];

  cell = [tableView dequeueReusableCellWithIdentifier:CrossingCellID];
  if (!cell) {
    cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CrossingCellID];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
  }

  cell.textLabel.text = crossing.name;
  cell.detailTextLabel.text = crossing.isClosest ? @"Ближний" : nil;
  if (self.accessoryType == UITableViewCellAccessoryCheckmark) {
    cell.accessoryType = crossing == model.selectedCrossing ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
  } else {
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }

  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];

  if (self.accessoryType == UITableViewCellAccessoryCheckmark) {
    for (UITableViewCell *cell in self.tableView.visibleCells)
      if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
        cell.accessoryType = UITableViewCellAccessoryNone;

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
  }

  if (self.target && self.action) {
    Crossing *crossing = [model.crossings objectAtIndex:indexPath.row];
    [self.target performSelector:self.action withObject:crossing];
  }
}

@end
