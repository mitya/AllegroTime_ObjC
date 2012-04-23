//
//  Created by Dima on 03.04.12.
//

#import "CrossingScheduleController.h"
#import "Models.h"
#import "TrainScheduleController.h"
#import "Helpers.h"

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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.crossing.closings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *ScheduleCellID = @"ScheduleCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ScheduleCellID];
  if (!cell) {
    cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:ScheduleCellID];
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

  cell.textLabel.text = closing.toRussia ? [NSString stringWithFormat:@"%@ ↶", closing.time] : closing.time; // ↺ ← →
  cell.detailTextLabel.text = [NSString stringWithFormat:@"№%i", closing.trainNumber];

  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  TrainScheduleController *trainScheduleController = [[TrainScheduleController alloc] initWithStyle:UITableViewStyleGrouped];
  trainScheduleController.sampleClosing = [self.crossing.closings objectAtIndex:indexPath.row];
  [self.navigationController pushViewController:trainScheduleController animated:YES];
}

@end
