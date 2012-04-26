//
//  CrossingListController.m
//  AllegroTime
//
//  Created by Dmitry Sokurenko on 28.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

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

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  NSIndexPath *const currentRowIndex = [NSIndexPath indexPathForRow:model.currentCrossing.index inSection:0];
  [self.tableView scrollToRowAtIndexPath:currentRowIndex atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return MXAutorotationPolicy(interfaceOrientation);
}

#pragma mark - table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return model.crossings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  Crossing *crossing = [model.crossings objectAtIndex:indexPath.row];

  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MXDefaultCellID];
  if (!cell) {
    cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MXDefaultCellID];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
  }

  cell.imageView.image = nil;
  cell.textLabel.text = crossing.name;
  cell.detailTextLabel.text = crossing.subtitle;
  cell.imageView.image = ([UIImage imageNamed:[NSString stringWithFormat:@"Data/Images/cell-stripe-%@.png", MXNameForColor(crossing.color)]]);

  if (self.accessoryType == UITableViewCellAccessoryCheckmark) {
    cell.accessoryType = crossing == model.currentCrossing ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  //UILabel *label = [Helper labelForTableViewFooter];
  UILabel *label = MXConfigureLabelLikeInTableViewFooter([UILabel new]);
  label.text = !model.closestCrossing ?
      @"Ближайший переезд не определен" :
      [NSString stringWithFormat:@"Ближайший — %@", model.closestCrossing.name];
  return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 30;
}


@end
