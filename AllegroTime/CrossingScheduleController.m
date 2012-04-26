//
//  Created by Dima on 03.04.12.
//

#import "CrossingScheduleController.h"
#import "Models.h"
#import "TrainScheduleController.h"
#import "AppDelegate.h"
#import "CrossingMapController.h"

@implementation CrossingScheduleController
@synthesize crossing;

- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = self.crossing.name;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return MXAutorotationPolicy(interfaceOrientation);
}

#pragma mark - table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 1) return 1;
  else return self.crossing.closings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 1) {
    UITableViewCell *cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.textLabel.text = @"Переезд на карте";
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i км", crossing.distance];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
  }

  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MXDefaultCellID];
  if (!cell) {
    cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:MXDefaultCellID];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:18];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:12];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
  }

  cell.textLabel.textColor = [Helper blueTextColor];
  cell.detailTextLabel.textColor = [UIColor grayColor];

  Closing *closing = [crossing.closings objectAtIndex:indexPath.row];

  if (closing.isClosest) {
    cell.backgroundColor = MXCellGradientColorFor(closing.color);
    if (closing.color == [UIColor greenColor] || closing.color == [UIColor redColor]) {
      cell.textLabel.textColor = [UIColor whiteColor];
      cell.detailTextLabel.textColor = [UIColor lightTextColor];
    }
  }

  cell.textLabel.text = closing.toRussia ? [NSString stringWithFormat:@"%@ ↶", closing.time] : closing.time;
  cell.detailTextLabel.text = [NSString stringWithFormat:@"№%i", closing.trainNumber];

  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 1 && indexPath.row == 0) {
    [self showMap];
    return;
  }

  TrainScheduleController *trainScheduleController = [[TrainScheduleController alloc] initWithStyle:UITableViewStyleGrouped];
  trainScheduleController.sampleClosing = [self.crossing.closings objectAtIndex:indexPath.row];
  [self.navigationController pushViewController:trainScheduleController animated:YES];
}

#pragma mark - handlers

- (void) showMap {
  AppDelegate* delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  if ([[self.navigationController viewControllers] containsObject:delegate.mapController]) {
    [self.navigationController popToViewController:delegate.mapController animated:YES];
  } else {
    [self.navigationController pushViewController:delegate.mapController animated:YES];
  }
  [delegate.mapController showCrossing:self.crossing];
}

@end
