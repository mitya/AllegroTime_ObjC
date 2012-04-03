//
//  Created by Dima on 03.04.12.
//


#import "CrossingScheduleController.h"
#import "Models.h"


@implementation CrossingScheduleController
@synthesize crossing;

- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = self.crossing.name;
}

#pragma mark - table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.crossing.closings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *ScheduleCellID = @"ScheduleCell";

  Closing *closing = [crossing.closings objectAtIndex:indexPath.row];

  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ScheduleCellID];
  if (!cell) {
    cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:ScheduleCellID];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:18];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }

  cell.textLabel.text = closing.time;
  cell.textLabel.textColor = closing.toRussia ? [UIColor colorWithRed:0 green:0 blue:0.5 alpha:1] : [UIColor colorWithRed:0 green:0.3 blue:0 alpha:1];
  cell.detailTextLabel.text = [NSString stringWithFormat:@"№%i %@ СПб", closing.trainNumber, closing.toRussia ? @"на" : @"от"];

  return cell;
}

@end