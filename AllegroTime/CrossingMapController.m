//
//  CrossingMapController.m
//  AllegroTime
//
//  Created by Dmitry Sokurenko on 19.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CrossingMapController.h"
#import "Models.h"
#import "CrossingScheduleController.h"

@interface CrossingMapController ()
@property (nonatomic, strong) MKMapView *map;
@end

@implementation CrossingMapController {
  BOOL mapRegionSet;
}
@synthesize map;

- (void)loadView {
  self.map = [[MKMapView alloc] init];
  self.map.showsUserLocation = [CLLocationManager locationServicesEnabled];
  self.map.delegate = self;
  self.view = self.map;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  NSArray *segmentedItems = [NSArray arrayWithObjects:@"Стандарт", @"Спутник", @"Гибрид", nil];
  UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentedItems];
  segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
  segmentedControl.selectedSegmentIndex = map.mapType;
  [segmentedControl addTarget:self action:@selector(changeMapType:) forControlEvents:UIControlEventValueChanged];

  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
  self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Карта" style:UIBarButtonItemStylePlain target:nil action:nil];

  [map addAnnotations:model.crossings];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  if (!mapRegionSet) {
    [map setRegion:MKCoordinateRegionMakeWithDistance([Crossing getCrossingWithName:@"Парголово"].coordinate, 10000, 10000) animated:YES];
    mapRegionSet = YES;
  }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return MXAutorotationPolicy(interfaceOrientation);
}

#pragma mark - map view

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
  if (![annotation isKindOfClass:[Crossing class]])
    return nil;

  static NSString *PinID = @"CrossingPin";
  Crossing *crossing = (Crossing *) annotation;

  MKAnnotationView *pin = [mapView dequeueReusableAnnotationViewWithIdentifier:PinID];
  if (pin == nil) {
    pin = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:PinID];
  }

  pin.annotation = crossing;
  pin.canShowCallout = YES;
  pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];

  if (crossing.color == [UIColor greenColor]) {
    pin.image = [UIImage imageNamed:@"Data/Images/pin.v4-green.png"];
  } else if (crossing.color == [UIColor redColor]) {
    pin.image = [UIImage imageNamed:@"Data/Images/pin.v4-red.png"];
  } else if (crossing.color == [UIColor yellowColor]) {
    pin.image = [UIImage imageNamed:@"Data/Images/pin.v4-yellow.png"];
  }

  return pin;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
  if (![view.annotation isKindOfClass:[Crossing class]])
    return;

  Crossing *crossing = (Crossing *) view.annotation;

  CrossingScheduleController *scheduleController = [[CrossingScheduleController alloc] initWithStyle:UITableViewStyleGrouped];
  scheduleController.crossing = crossing;
  [self.navigationController pushViewController:scheduleController animated:YES];
}

#pragma mark - callbacks

- (void)changeMapType:(UISegmentedControl *)segment {
  map.mapType = segment.selectedSegmentIndex;
}

@end
