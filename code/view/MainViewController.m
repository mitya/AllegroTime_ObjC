#import <CoreLocation/CoreLocation.h>
#import "MainViewController.h"
#import "CrossingListController.h"
#import "CrossingScheduleController.h"
#import "CrossingMapController.h"
#import "LogViewController.h"
#import "AboutController.h"
#import "GADBannerView.h"

const int StateSection = 0;
const int ActionsSection = 1;

@interface MainViewController ()
@property (strong, nonatomic) IBOutlet UITableViewCell *crossingCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *stateCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *stateDetailsCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *showScheduleCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *showMapCell;
@property (strong, nonatomic) IBOutlet UIView *stateSectionHeader;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *stateCellTopLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *stateCellBottomLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation MainViewController {
  GADBannerView *bannerView
  BOOL bannerViewLoaded;
}

@synthesize crossingCell;
@synthesize stateCell;
@synthesize stateDetailsCell;
@synthesize showScheduleCell;
@synthesize showMapCell;
@synthesize stateCellTopLabel;
@synthesize stateCellBottomLabel;
@synthesize stateSectionHeader;
@synthesize tableView;

#pragma mark - lifecycle

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
  self.title = T("main.title");
  self.view.backgroundColor = MXIsPhone() ? [UIColor groupTableViewBackgroundColor] : MXPadTableViewBackgroundColor();

  self.navigationItem.backBarButtonItem = [UIBarButtonItem.alloc initWithTitle:T("main.backbutton") style:UIBarButtonItemStyleBordered target:nil action:nil];

  UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
  [infoButton addTarget:self action:@selector(showInfo) forControlEvents:UIControlEventTouchUpInside];
  self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithCustomView:infoButton];

  #if DEBUG
    UISwipeGestureRecognizer *swipeRecognizer = [UISwipeGestureRecognizer.alloc initWithTarget:self action:@selector(recognizedSwipe:)];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeRecognizer];
  #endif

  [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(closestCrossingChanged) name:NXClosestCrossingChanged object:nil];

  [self setupBanner];
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
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  // if we returned from another screen where the orientation was changed
  if (bannerViewLoaded && bannerView.frame.size.width != self.view.frame.size.width) {
    [self resetBannerFor:self.interfaceOrientation];
  }
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return MXAutorotationPolicy(interfaceOrientation);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
  if (bannerViewLoaded) {
    [self resetBannerFor:toInterfaceOrientation];
  }
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

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

  if (cell == crossingCell) [self showCrossingListToChangeCurrent];
  else if (cell == showScheduleCell) [self showCrossingListForSchedule];
  else if (cell == showMapCell) [self showMap];
}

#pragma mark - banner

- (void)setupBanner {
  bannerView = [GADBannerView.alloc initWithAdSize:UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? kGADAdSizeSmartBannerLandscape : kGADAdSizeSmartBannerPortrait];
  bannerView.adUnitID = MXIsPhone() ? GAD_IPHONE_KEY : GAD_IPAD_KEY;
  bannerView.rootViewController = self;
  bannerView.backgroundColor = self.view.backgroundColor;
  bannerView.delegate = self;
  bannerView.hidden = YES;

  if (MXIsPhone()) {
    bannerView.frame = CGRectMake(0, self.view.bounds.size.height - bannerView.bounds.size.height, bannerView.bounds.size.width, bannerView.bounds.size.height);
  } else {
    bannerView.frame = CGRectMake((self.view.bounds.size.width - GAD_IPAD_WIDTH) / 2, self.view.bounds.size.height - bannerView.bounds.size.height, GAD_IPAD_WIDTH, bannerView.bounds.size.height);
    bannerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
  }

  [self.view addSubview:bannerView];

  GADRequest *adRequest = [GADRequest request];
  adRequest.testing = DEBUG ? YES : NO;
  [bannerView loadRequest:adRequest];
}

- (void)adViewDidReceiveAd:(GADBannerView *)banner {
  if (!bannerViewLoaded || MXIsPhone()) {
    bannerView.frame = CGRectMake(banner.frame.origin.x, self.view.bounds.size.height, banner.frame.size.width, banner.frame.size.height);
    [UIView animateWithDuration:0.25 animations:^{
      banner.hidden = NO;
      banner.frame = CGRectMake(banner.frame.origin.x, self.view.bounds.size.height - banner.frame.size.height, banner.frame.size.width, banner.frame.size.height);
      tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - banner.bounds.size.height);
    }];
  }

  bannerViewLoaded = YES;
}

- (void)resetBannerFor:(UIInterfaceOrientation)orientation {
  if (MXIsPhone()) {
    bannerView.hidden = YES;
    bannerView.adSize = UIInterfaceOrientationIsLandscape(orientation) ? kGADAdSizeSmartBannerLandscape : kGADAdSizeSmartBannerPortrait;
    tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
  }
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
