//
//  Created by Dima on 03.04.12.
//


#import "TrainScheduleController.h"
#import "Models.h"
#import "Helpers.h"


@implementation TrainScheduleController
@synthesize sampleClosing;

- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = [NSString stringWithFormat:@"Поезд №%i", self.sampleClosing.trainNumber];
}

#pragma mark - table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return model.crossings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellID = @"TrainScheduleCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
  if (!cell) {
    cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:18];
    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:12];
  }

  int trainIndex = [self.sampleClosing.crossing.closings indexOfObject:self.sampleClosing];
  Crossing *crossing = [model.crossings objectAtIndex:indexPath.row];
  Closing *closing = [crossing.closings objectAtIndex:trainIndex];

  cell.textLabel.text = closing.time;
  cell.detailTextLabel.text = closing.crossing.name;

  return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  UILabel *label = [Helper labelForTableViewFooter];
  label.text = self.sampleClosing.toRussia ? @"Из Хельсинки в Санкт-Петербург" : @"Из Санкт-Петербурга в Хельсинки";
  return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 30;
}


@end