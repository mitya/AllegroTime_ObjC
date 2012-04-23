//
//  Created by Dima on 23.04.12.
//


#import <CoreGraphics/CoreGraphics.h>
#import "Helpers.h"
#import "LogViewController.h"


@interface LogViewController ()
@property (nonatomic, strong) UITextView *log;
@property (nonatomic, strong) NSMutableString *logText;
@property (nonatomic, strong) UITableView *table;
@end

@implementation LogViewController
@synthesize log;
@synthesize logText;
@synthesize table;


- (void)viewDidLoad {
  [super viewDidLoad];

  self.title = @"Лог";

  table = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
  table.delegate = self;
  table.dataSource = self;
  [self.view addSubview:table];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return MXConsoleGet().count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellID = @"LogCell";
  UITableViewCell *cell;

  cell = [tableView dequeueReusableCellWithIdentifier:CellID];
  if (!cell) {
    cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
  }

  cell.textLabel.text = [MXConsoleGet() objectAtIndex:indexPath.row];

  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *message = [MXConsoleGet() objectAtIndex:indexPath.row];
  UIFont *font = [UIFont systemFontOfSize:12];
  CGSize constraintSize = CGSizeMake(table.bounds.size.width - 20, MAXFLOAT);
  CGSize labelSize = [message sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
  return labelSize.height + 6;
}


@end