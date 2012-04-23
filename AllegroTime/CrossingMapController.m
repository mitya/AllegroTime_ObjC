//
//  CrossingMapController.m
//  AllegroTime
//
//  Created by Dmitry Sokurenko on 19.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "CrossingMapController.h"
#import "Models.h"
#import "CrossingScheduleController.h"

static MKCoordinateRegion CrossingMapController_LastRegion;
static MKMapType CrossingMapController_LastMapType = MKMapTypeStandard;

@interface CrossingMapController ()
@property (nonatomic, strong) MKMapView *map;
@end

@implementation CrossingMapController
@synthesize map;

- (void)loadView {
  self.map = [[MKMapView alloc] init];
  self.map.showsUserLocation = YES;
  self.map.delegate = self;
  self.map.mapType = CrossingMapController_LastMapType;
  self.view = self.map;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  NSArray *segmentedItems = [NSArray arrayWithObjects:@"Standard", @"Hybrid", @"Satellite", nil];
  UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentedItems];
  segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
  segmentedControl.selectedSegmentIndex = CrossingMapController_LastMapType;
  [segmentedControl addTarget:self action:@selector(changeMapType:) forControlEvents:UIControlEventValueChanged];

  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
  self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Карта" style:UIBarButtonItemStylePlain target:nil action:nil];

  //self.toolbarItems = [NSArray arrayWithObjects:
  //    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
  //    [[UIBarButtonItem alloc] initWithCustomView:segmentedControl],
  //    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
  //    nil];
  //[self.navigationController setToolbarHidden:NO animated:YES];


  [map addAnnotations:model.crossings];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  if (CrossingMapController_LastRegion.span.latitudeDelta != 0) {
    [map setRegion:CrossingMapController_LastRegion animated:YES];
  } else {
    [map setRegion:MKCoordinateRegionMakeWithDistance([Crossing getCrossingWithName:@"Парголово"].coordinate, 10000, 10000) animated:YES];
  }
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  CrossingMapController_LastRegion = map.region;
  CrossingMapController_LastMapType = map.mapType;
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
  switch (segment.selectedSegmentIndex) {
    case 0:
      map.mapType = MKMapTypeStandard;
      break;
    case 1:
      map.mapType = MKMapTypeSatellite;
      break;
    case 2:
      map.mapType = MKMapTypeHybrid;
      break;
  }
}

@end
