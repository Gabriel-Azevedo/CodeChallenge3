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
    UIAlertView *alert = [UIAlertView new];
    alert.title = @"GEO Code Error";
    [alert addButtonWithTitle:@"Dismiss"];
    [alert show];
    [self getPathDirectionswithDestination];
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

    NSLog(@"source = %f, %f",self.station.userCurrentLocation.coordinate.latitude, self.station.userCurrentLocation.coordinate.longitude);

    CLLocationCoordinate2D sourceCoordinate = CLLocationCoordinate2DMake(self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
    MKPlacemark *placemarkSrc = [[MKPlacemark alloc] initWithCoordinate:sourceCoordinate addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"", @"", nil]];
    MKMapItem *destination = [[MKMapItem alloc] initWithPlacemark:placemarkSrc];
    [destination setName:@""];

    NSLog(@"dest = %f, %f", [self.station.latitude doubleValue], [self.station.longitude doubleValue]);

    CLLocationDegrees latitude = [self.station.latitude doubleValue];
    CLLocationDegrees longitude = [self.station.longitude doubleValue];
    CLLocationCoordinate2D destinationCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    MKPlacemark *placemarkDest = [[MKPlacemark alloc] initWithCoordinate:destinationCoordinate addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"", @"", nil]];
    MKMapItem *source = [[MKMapItem alloc] initWithPlacemark:placemarkDest];
    [source setName:@""];


    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    [request setSource:source];
    [request setDestination:destination];
    [request setTransportType:MKDirectionsTransportTypeWalking];
    //request.requestsAlternateRoutes = NO;


    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];

    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        MKRoute *route = response.routes.lastObject;

        NSString *allSteps = [NSString new];

        for (int i = 0; i < route.steps.count; i++)
        {
            MKRouteStep *step = [route.steps objectAtIndex:i];
            NSString *newStepString = step.instructions;
            allSteps = [allSteps stringByAppendingString:newStepString];
            allSteps = [allSteps stringByAppendingString:@"\n\n"];
        }
        NSLog(@"%@",[NSString stringWithFormat:@"%@", allSteps]);
    }];
}


@end
