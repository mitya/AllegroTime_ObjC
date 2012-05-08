#import <CoreLocation/CoreLocation.h>
#import <CoreGraphics/CoreGraphics.h>
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
  GADBannerView *bannerView;
  NSTimer *adTimer;
  BOOL bannerViewLoaded;
  BOOL adReloadPending;
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
@synthesize adReloadPending;


#pragma mark - lifecycle

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
  self.title = T("main.title");
  self.view.backgroundColor = IPHONE ? [UIColor groupTableViewBackgroundColor] : MXPadTableViewBackgroundColor();
  self.navigationItem.backBarButtonItem = [UIBarButtonItem.alloc initWithTitle:T("main.backbutton") style:UIBarButtonItemStyleBordered target:nil action:nil];

  [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(closestCrossingChanged) name:NXClosestCrossingChanged object:nil];
  
  [self createInfoButton];
  [self setupBanner];
  [self setupLogConsoleGesture];

  adTimer = [NSTimer scheduledTimerWithTimeInterval:GAD_REFRESH_PERIOD target:self selector:@selector(adTimerTicked) userInfo:nil repeats:YES];
}

- (void)createInfoButton {
  UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
  [infoButton addTarget:self action:@selector(showInfo) forControlEvents:UIControlEventTouchUpInside];
  self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithCustomView:infoButton];
}

- (void)setupLogConsoleGesture {
  if (DEBUG) {
    UISwipeGestureRecognizer *swipeRecognizer = [UISwipeGestureRecognizer.alloc initWithTarget:self action:@selector(recognizedSwipe:)];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeRecognizer];
  }
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
  [self performDelayedBannerReload];
}

- (void)performDelayedBannerReload {
  if (adReloadPending) {
    adReloadPending = NO;
    [self reloadBanner];
  }
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

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

  if (cell == crossingCell) [self showCrossingListToChangeCurrent];
  else if (cell == showScheduleCell) [self showCrossingListForSchedule];
  else if (cell == showMapCell) [self showMap];
}

#pragma mark - banner

- (void)setupBanner {
  bannerView = [GADBannerView.alloc initWithAdSize:IPHONE ? kGADAdSizeBanner : kGADAdSizeLeaderboard];
  bannerView.adUnitID = IPHONE ? GAD_IPHONE_KEY : GAD_IPAD_KEY;
  bannerView.rootViewController = self;
  bannerView.backgroundColor = [UIColor clearColor];
  bannerView.delegate = self;
  bannerView.hidden = YES;
  bannerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
  bannerView.frame = CGRectMake(bannerView.bounds.origin.x, self.view.bounds.size.height - bannerView.bounds.size.height, bannerView.bounds.size.width, bannerView.bounds.size.height);

  [self.view addSubview:bannerView];
  [self reloadBanner];
}

- (void)reloadBanner {
  GADRequest *adRequest = [GADRequest request];
  adRequest.testing = GAD_TESTING_MODE;

  CLLocation *location = app.locationManager.location;
  if (location) {
    [adRequest setLocationWithLatitude:(CGFloat) location.coordinate.latitude longitude:(CGFloat) location.coordinate.longitude accuracy:(CGFloat) location.horizontalAccuracy];
  }

  [bannerView loadRequest:adRequest];
}

- (void)adTimerTicked {
  NSLog(@"%s ", __cmd);

  if (bannerViewLoaded) {
    if (self.navigationController.visibleViewController == self)
      [self reloadBanner];
    else
      adReloadPending = YES;
  }
}

- (void)adViewDidReceiveAd:(GADBannerView *)banner {
  NSLog(@"%s ", __cmd);
  if (!bannerViewLoaded) {
    bannerView.frame = CGRectMake(banner.frame.origin.x, self.view.bounds.size.height, banner.frame.size.width, banner.frame.size.height);
    [UIView animateWithDuration:0.25 animations:^{
      banner.hidden = NO;
      banner.frame = CGRectMake(banner.frame.origin.x, self.view.bounds.size.height - banner.frame.size.height, banner.frame.size.width, banner.frame.size.height);
    }];
    bannerViewLoaded = YES;
  }
}

 - (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
   NSLog(@"adView:didFailToReceiveAdWithError: %@", error);
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
