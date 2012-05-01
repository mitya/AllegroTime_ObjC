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

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.title = @"Лог";

  table = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
  table.delegate = self;
  table.dataSource = self;
  table.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self.view addSubview:table];

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(consoleUpdated) name:NXLogConsoleUpdated object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(consoleFlushed) name:NXLogConsoleFlushed object:nil];

  UISwipeGestureRecognizer* swipeRecognizer = [UISwipeGestureRecognizer.alloc initWithTarget:self action:@selector(recognizedSwipe:)];
  swipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
  [self.view addGestureRecognizer:swipeRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  return MXAutorotationPolicy(toInterfaceOrientation);
}

#pragma mark - handlers

- (void)consoleUpdated {
  CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();

  if ([[table indexPathsForVisibleRows] containsObject:[NSIndexPath indexPathForRow:0 inSection:0]] && [table numberOfRowsInSection:0] == MXGetConsole().count - 1) {
    [table insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
  } else {
    [table reloadData];
  }

  NSLog(@"%s updated in %fs", __func__, startTime - CFAbsoluteTimeGetCurrent());
}

- (void)consoleFlushed {
  [table reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationMiddle];
}

- (void)recognizedSwipe:(UISwipeGestureRecognizer *)recognizer {
  const CGPoint point = [recognizer locationInView:self.view];
  if (point.y > 300)
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return MXGetConsole().count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSArray *console = MXGetConsole();
  NSString *message = [console objectAtIndex:(console.count - 1 - indexPath.row)];

  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MXDefaultCellID];
  if (!cell) {
    cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MXDefaultCellID];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
  }

  cell.textLabel.text = message;

  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSArray *console = MXGetConsole();
  NSString *message = [console objectAtIndex:(console.count - 1 - indexPath.row)];
  UIFont *font = [UIFont systemFontOfSize:12];
  CGSize constraintSize = CGSizeMake(table.bounds.size.width - 20, MAXFLOAT);
  CGSize labelSize = [message sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
  return labelSize.height + 6;
}


@end