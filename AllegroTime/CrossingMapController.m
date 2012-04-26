//
//  CrossingMapController.m
//  AllegroTime
//
//  Created by Dmitry Sokurenko on 19.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "CrossingMapController.h"
#import "CrossingScheduleController.h"

@interface CrossingMapController ()
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) NSDictionary *pinMapping;
@end

@implementation CrossingMapController {
  NSTimer *timer;
  MKCoordinateRegion lastRegion;
  MKMapType lastMapType;
}
@synthesize mapView;
@synthesize pinMapping;

- (id)init {
  self = [super init];
  lastMapType = MKMapTypeStandard;
  lastRegion = MKCoordinateRegionMakeWithDistance([Crossing getCrossingWithName:@"Парголово"].coordinate, 10000, 10000);
  return self;
}

- (void)loadView {
  self.mapView = [[MKMapView alloc] init];
  self.mapView.showsUserLocation = [CLLocationManager locationServicesEnabled];
  self.mapView.delegate = self;
  self.mapView.mapType = lastMapType;
  self.view = self.mapView;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.title = @"Карта";

  NSArray *segmentedItems = [NSArray arrayWithObjects:@"Стандарт", @"Спутник", @"Гибрид", nil];
  UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentedItems];
  segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
  segmentedControl.selectedSegmentIndex = lastMapType;
  [segmentedControl addTarget:self action:@selector(changeMapType:) forControlEvents:UIControlEventValueChanged];

  self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Карта" style:UIBarButtonItemStylePlain target:nil action:nil];

  NSMutableArray *itemsForToolbar = [NSMutableArray arrayWithObjects:
      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
      [[UIBarButtonItem alloc] initWithCustomView:segmentedControl],
      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
      nil];
  if (self.mapView.showsUserLocation) {
    UIImage *userLocationIcon = [UIImage imageNamed:@"Data/Images/bb-location.png"];
    UIBarButtonItem *userLocationButton = [[UIBarButtonItem alloc] initWithImage:userLocationIcon style:UIBarButtonItemStyleBordered target:self action:@selector(showUserLocation)];
    [itemsForToolbar insertObject:userLocationButton atIndex:0];
  }
  self.toolbarItems = itemsForToolbar;

  [mapView addAnnotations:model.crossings];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [mapView setRegion:lastRegion animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewDidAppear:animated];

  lastMapType = mapView.mapType;
  lastRegion = mapView.region;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return MXAutorotationPolicy(interfaceOrientation);
}

#pragma mark - methods

- (void)showCrossing:(Crossing *)aCrossing {
  [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(aCrossing.coordinate, 7000, 7000) animated:NO];
  [self.mapView selectAnnotation:aCrossing animated:NO];
}

#pragma mark - map view

- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id <MKAnnotation>)annotation {
  if (![annotation isKindOfClass:[Crossing class]]) return nil;

  Crossing *crossing = (Crossing *) annotation;

  MKAnnotationView *pin = [mapView dequeueReusableAnnotationViewWithIdentifier:MXDefaultCellID];
  if (pin == nil) {
    pin = [[MKAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:MXDefaultCellID];
    pin.canShowCallout = YES;
    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
  }
  pin.annotation = crossing;
  pin.image = [self.pinMapping objectForKey:crossing.color];

  return pin;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
  if (![view.annotation isKindOfClass:[Crossing class]]) return;

  Crossing *crossing = (Crossing *) view.annotation;
  CrossingScheduleController *scheduleController = [[CrossingScheduleController alloc] initWithStyle:UITableViewStyleGrouped];
  scheduleController.crossing = crossing;
  [self.navigationController pushViewController:scheduleController animated:YES];
}

#pragma mark - callbacks

- (void)changeMapType:(UISegmentedControl *)segment {
  mapView.mapType = segment.selectedSegmentIndex;
}

- (void)modelUpdated {
  for (Crossing *crossing in mapView.annotations) {
    MKAnnotationView *annotationView = [mapView viewForAnnotation:crossing];
    if (![crossing isKindOfClass:[Crossing class]]) continue;
    if (!annotationView) continue;
    UIImage *newImage = [self.pinMapping objectForKey:crossing.color];
    if (annotationView.image != newImage) annotationView.image = newImage;
  }
}

- (void)showUserLocation {
  MKUserLocation *const userLocation = [self.mapView userLocation];
  if (userLocation.coordinate.latitude != 0 && userLocation.coordinate.latitude != 0) {
    [self.mapView setCenterCoordinate:userLocation.coordinate animated:YES];
  }
}

#pragma mark - helpers

- (NSDictionary *)pinMapping {
  if (!pinMapping) {
    pinMapping = [NSDictionary dictionaryWithObjectsAndKeys:
        [UIImage imageNamed:@"Data/Images/crossing-pin-green.png"], [UIColor greenColor],
        [UIImage imageNamed:@"Data/Images/crossing-pin-yellow.png"], [UIColor yellowColor],
        [UIImage imageNamed:@"Data/Images/crossing-pin-red.png"], [UIColor redColor],
        nil];
  }
  return pinMapping;
}

@end
