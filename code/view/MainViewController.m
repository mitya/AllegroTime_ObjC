#import <CoreLocation/CoreLocation.h>
#import "MainViewController.h"
#import "CrossingListController.h"
#import "CrossingScheduleController.h"
#import "CrossingMapController.h"
#import "LogViewController.h"
#import "AboutController.h"

const int StateSection = 0;
const int ActionsSection = 1;

@interface MainViewController ()
@property (nonatomic, strong) NSTimer *timer;
@property (strong, nonatomic) IBOutlet UITableViewCell *crossingCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *stateCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *stateDetailsCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *showScheduleCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *showMapCell;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *stateCellTopLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *stateCellBottomLabel;
@property (strong, nonatomic) IBOutlet UIView *stateSectionHeader;
@end

@implementation MainViewController
@synthesize timer;
@synthesize crossingCell;
@synthesize stateCell;
@synthesize stateDetailsCell;
@synthesize showScheduleCell;
@synthesize showMapCell;
@synthesize stateCellTopLabel;
@synthesize stateCellBottomLabel;
@synthesize stateSectionHeader;

#pragma mark - lifecycle

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.title = T("main.title");

  self.navigationItem.backBarButtonItem = [UIBarButtonItem.alloc initWithTitle:T("main.backbutton") style:UIBarButtonItemStyleBordered target:nil action:nil];


  //UIImage *infoButtonImage = MXImageFromFile(@"bb-info.png");
  //UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithImage:infoButtonImage style:UIBarButtonItemStyleBordered target:self action:@selector(showInfo)];
  //self.navigationItem.rightBarButtonItem = infoButton;

  UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
  [infoButton addTarget:self action:@selector(showInfo) forControlEvents:UIControlEventTouchUpInside];
  self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithCustomView:infoButton];

  UISwipeGestureRecognizer *swipeRecognizer = [UISwipeGestureRecognizer.alloc initWithTarget:self action:@selector(recognizedSwipe:)];
  swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
  [self.view addGestureRecognizer:swipeRecognizer];

  [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(closestCrossingChanged) name:NXClosestCrossingChanged object:nil];
}

- (void)viewDidUnload {
  [self setShowMapCell:nil];
  [self setShowScheduleCell:nil];
  [self setStateDetailsCell:nil];
  [self setStateCellTopLabel:nil];
  [self setStateCellBottomLabel:nil];
  [self setStateCell:nil];
  [self setCrossingCell:nil];
  [self setStateSectionHeader:nil];
  [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return MXAutorotationPolicy(interfaceOrientation);
}


#pragma mark - table view stuff

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == StateSection) return 3;
  if (section == ActionsSection) return 2;
  else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell;

  if (indexPath.section == StateSection && indexPath.row == 0) {
    cell = self.crossingCell;
    cell.detailTextLabel.text = model.currentCrossing.name;
  } else if (indexPath.section == StateSection && indexPath.row == 1) {
    cell = self.stateCell;
    Closing *nextClosing = model.currentCrossing.nextClosing;
    stateCellTopLabel.text = TF("main. allegro will pass at $time", [Helper formatTimeInMunutesAsHHMM:nextClosing.trainTime]);
    stateCellBottomLabel.text = TF("main. crossing $closes at $time",
        model.currentCrossing.state == CrossingStateClosed ? @"закрыли" : @"закроют",
        [Helper formatTimeInMunutesAsHHMM:nextClosing.closingTime]);
  } else if (indexPath.section == StateSection && indexPath.row == 2) {
    cell = self.stateDetailsCell;
    MXSetGradientForCell(cell, model.currentCrossing.color);
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.text = model.currentCrossing.subtitle;

  } else if (indexPath.section == ActionsSection) {
    if (indexPath.row == 0) cell = self.showScheduleCell;
    if (indexPath.row == 1) cell = self.showMapCell;
  }

  return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
  if (section == ActionsSection) return T("main.footer");
  else return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

  if (cell == crossingCell) [self showCrossingListToChangeCurrent];
  else if (cell == showScheduleCell) [self showCrossingListForSchedule];
  else if (cell == showMapCell) [self showMap];
}


#pragma mark - handlers

- (void)recognizedSwipe:(UISwipeGestureRecognizer *)recognizer {
  CGPoint point = [recognizer locationInView:self.view];
  if (point.y > 300)
    [self showLog];
}

- (void)modelUpdated {
  [self.tableView reloadData];
}

- (void)closestCrossingChanged {
  [self.tableView reloadData];
}

- (void)showInfo {
  AboutController *aboutController = [[AboutController alloc] init];
  [self.navigationController pushViewController:aboutController animated:YES];
}

- (void)showMap {
  [self.navigationController pushViewController:app.mapController animated:YES];
}

- (void)showCrossingListForSchedule {
  CrossingListController *crossingsController = [[CrossingListController alloc] initWithStyle:UITableViewStyleGrouped];
  crossingsController.target = self;
  crossingsController.action = @selector(showScheduleForCrossing:);
  crossingsController.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  [self.navigationController pushViewController:crossingsController animated:YES];
}

- (void)showCrossingListToChangeCurrent {
  CrossingListController *crossingsController = [[CrossingListController alloc] initWithStyle:UITableViewStyleGrouped];
  crossingsController.target = self;
  crossingsController.action = @selector(changeCurrentCrossing:);
  crossingsController.accessoryType = UITableViewCellAccessoryCheckmark;
  [self.navigationController pushViewController:crossingsController animated:YES];
}

- (void)showScheduleForCrossing:(Crossing *)crossing {
  CrossingScheduleController *scheduleController = [[CrossingScheduleController alloc] initWithStyle:UITableViewStyleGrouped];
  scheduleController.crossing = crossing;
  [self.navigationController pushViewController:scheduleController animated:YES];
}

- (void)showLog {
  LogViewController *logController = [[LogViewController alloc] init];
  [self.navigationController pushViewController:logController animated:YES];
}

- (void)changeCurrentCrossing:(Crossing *)crossing {
  [model setCurrentCrossing:crossing];
  [self.navigationController popViewControllerAnimated:YES];
  [self.tableView reloadData];
}

@end