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

@interface CrossingMapController ()
@property (nonatomic, strong) MKMapView *map;
@property (nonatomic, strong) NSDictionary *pinMapping;
@end

@implementation CrossingMapController {
  NSTimer *timer;
  MKCoordinateRegion lastRegion;
  MKMapType lastMapType;
}
@synthesize map;
@synthesize pinMapping;

- (id)init {
  self = [super init];
  lastMapType = MKMapTypeStandard;
  lastRegion = MKCoordinateRegionMakeWithDistance([Crossing getCrossingWithName:@"Парголово"].coordinate, 10000, 10000);
  return self;
}

- (void)loadView {
  self.map = [[MKMapView alloc] init];
  self.map.showsUserLocation = [CLLocationManager locationServicesEnabled];
  self.map.delegate = self;
  self.map.mapType = lastMapType;
  self.view = self.map;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  NSArray *segmentedItems = [NSArray arrayWithObjects:@"Стандарт", @"Спутник", @"Гибрид", nil];
  UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentedItems];
  segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
  segmentedControl.selectedSegmentIndex = lastMapType;
  [segmentedControl addTarget:self action:@selector(changeMapType:) forControlEvents:UIControlEventValueChanged];

  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
  self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Карта" style:UIBarButtonItemStylePlain target:nil action:nil];

  [map addAnnotations:model.crossings];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  [map setRegion:lastRegion animated:YES];

  timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(timerTicked:) userInfo:nil repeats:YES];
  timer.fireDate = [Helper nextFullMinuteDate];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewDidAppear:animated];

  lastMapType = map.mapType;
  lastRegion = map.region;

  [timer invalidate];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return MXAutorotationPolicy(interfaceOrientation);
}

#pragma mark - map view

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
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
  map.mapType = segment.selectedSegmentIndex;
}

- (void)timerTicked:(NSTimer *)theTimer {
  MXWriteToConsole(@"map timerTicked %@", MXFormatDate([NSDate date], @"HH:mm:ss"));
  for (Crossing *crossing in map.annotations) {
    MKAnnotationView *annotationView = [map viewForAnnotation:crossing];
    if (![crossing isKindOfClass:[Crossing class]]) continue;
    if (!annotationView) continue;
    UIImage *newImage = [self.pinMapping objectForKey:crossing.color];
    if (annotationView.image != newImage) annotationView.image = newImage;
  }
}

#pragma mark - helpers

- (NSDictionary *)pinMapping {
  if (!pinMapping) {
    pinMapping = [NSDictionary dictionaryWithObjectsAndKeys:
        [UIImage imageNamed:@"Data/Images/pin.v4-green.png"], [UIColor greenColor],
        [UIImage imageNamed:@"Data/Images/pin.v4-yellow.png"], [UIColor yellowColor],
        [UIImage imageNamed:@"Data/Images/pin.v4-red.png"], [UIColor redColor],
        nil];
  }
  return pinMapping;
}

@end
