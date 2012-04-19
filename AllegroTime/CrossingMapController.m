//
//  CrossingMapController.m
//  AllegroTime
//
//  Created by Dmitry Sokurenko on 19.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CrossingMapController.h"
#import "Models.h"

@interface CrossingMapController ()
@property (nonatomic, strong) MKMapView *map;
@end

@implementation CrossingMapController
@synthesize map;

- (void)loadView {
  self.map = [[MKMapView alloc] init];
  self.view = self.map;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  map.showsUserLocation = YES;
  map.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [map setRegion:MKCoordinateRegionMakeWithDistance([Crossing getCrossingWithName:@"Парголово"].coordinate, 10000, 10000) animated:YES];
  [map addAnnotations:model.crossings];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
  if (![annotation isKindOfClass:[Crossing class]])
    return nil;

  Crossing *crossing = (Crossing *)annotation;

  MKAnnotationView *pin = [mapView dequeueReusableAnnotationViewWithIdentifier:@"CrossingPin"];

  if (pin == nil) {
    pin = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CrossingPin"];
  }

  pin.annotation = crossing;

  UIImage *const image = [UIImage imageNamed:@"Data/Images/pin-green.png"];
  NSLog(@"[%s] image:%@", (char *) _cmd, image);


  pin.image = [UIImage imageNamed:@"Data/Images/pin-green.png"];

  switch (crossing.stateColor) {
    case StateColorGreen:
      pin.image = [UIImage imageNamed:@"Data/Images/pin-green.png"];
      break;
    case StateColorRed:
      pin.image = [UIImage imageNamed:@"Data/Images/pin-red.png"];
      break;
    case StateColorYellow:
      pin.image = [UIImage imageNamed:@"Data/Images/pin-yellow.png"];
      break;
  }


  //switch (annotation.stateColor) {
  //  case StateColorGreen:
  //    pin.pinColor = MKPinAnnotationColorGreen;
  //    break;
  //  case StateColorRed:
  //    pin.pinColor = MKPinAnnotationColorRed;
  //    break;
  //  case StateColorYellow:
  //    pin.pinColor = MKPinAnnotationColorPurple;
  //    break;
  //}

  return pin;
}

@end
