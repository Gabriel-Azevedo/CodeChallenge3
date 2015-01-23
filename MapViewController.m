//
//  MapViewController.m
//  CodeChallenge3
//
//  Created by Vik Denic on 10/16/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>

@interface MapViewController () <MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property CLLocationManager *locationManager;
@property CLLocation *currentLocation;
@property NSString *allSteps;
@property UIAlertView *alert;

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self pinStation];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.locationManager = [CLLocationManager new];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if (![annotation.title isEqualToString:@"Current Location"])
    {
        MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
        pin.image = [UIImage imageNamed:@"bikeImage"];
        pin.canShowCallout = YES;
        pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        return pin;
    }
    else
    {
        return nil;
    }
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self getPathDirectionswithDestination];

    self.alert = [UIAlertView new];
    [self.alert addButtonWithTitle:@"Dismiss"];

}

-(void)pinStation
{
    CLLocationDegrees latitude = [self.station.latitude doubleValue];
    CLLocationDegrees longitude = [self.station.longitude doubleValue];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);

    MKPointAnnotation *annotation = [MKPointAnnotation new];
    annotation.title = self.station.name;
    annotation.coordinate = coordinate;

    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.05, 0.05));

    [self.mapView setRegion:region animated:YES];
    [self.mapView addAnnotation:annotation];
}




-(void) getPathDirectionswithDestination
{
    CLLocationDegrees latitude = [self.station.latitude floatValue];
    CLLocationDegrees longitude = [self.station.longitude floatValue];
    CLLocationCoordinate2D destinationCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    MKPlacemark *placemarkDest = [[MKPlacemark alloc] initWithCoordinate:destinationCoordinate addressDictionary:nil];
    MKMapItem *destination = [[MKMapItem alloc] initWithPlacemark:placemarkDest];

    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    [request setSource:[MKMapItem mapItemForCurrentLocation]];
    [request setDestination:destination];
    [request setTransportType:MKDirectionsTransportTypeWalking];

    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];

    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        MKRoute *route = response.routes.lastObject;

        self.allSteps = [NSString new];

        for (int i = 0; i < route.steps.count; i++)
        {
            MKRouteStep *step = [route.steps objectAtIndex:i];
            NSString *newStepString = step.instructions;
            self.allSteps = [self.allSteps stringByAppendingString:newStepString];
            self.allSteps = [self.allSteps stringByAppendingString:@"\n\n"];
        }
        self.alert.message = self.allSteps;
        [self.alert show];
    }];
}


@end
