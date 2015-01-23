//
//  StationsListViewController.m
//  CodeChallenge3
//
//  Created by Vik Denic on 10/16/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "StationsListViewController.h"
#import "MapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "Station.h"

@interface StationsListViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property NSArray *rawStationsArray;
@property NSMutableArray *stations;
@property NSMutableArray *searchedStations;
@property NSMutableArray *temporaryArray;


@property CLLocationManager *locationManager;
@property CLLocation *currentLocation;

@end

@implementation StationsListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.stations = [NSMutableArray new];
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    self.searchBar.delegate = self;

    [self.locationManager requestAlwaysAuthorization];
    [self updateCurrentLocation];
    [self parsingBusStops];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length == 0)
    {
        self.searchedStations = self.stations;
    }
    else{
        self.searchedStations = [NSMutableArray new];
        for (Station *station in self.stations)
        {
            NSRange nameRange = [station.name rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if(nameRange.location != NSNotFound)
            {
                [self.searchedStations addObject:station];
            }
        }
    }
    [self.tableView reloadData];
}



#pragma mark - CLLocationManager Methods
-(void)updateCurrentLocation
{
    [self.locationManager startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%@",error);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentLocation = locations.firstObject;
    //NSLog(@"%f",self.currentLocation.coordinate.latitude);
    if (self.currentLocation.verticalAccuracy < 100 && self.currentLocation.horizontalAccuracy < 100)
    {
        [self.locationManager stopUpdatingLocation];
    }

}

#pragma mark - UITableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchedStations.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    Station *station = [self.searchedStations objectAtIndex:indexPath.row];
    cell.textLabel.text = station.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Available Bikes = %li", station.availableBikes];
    return cell;
}


#pragma mark - Custom Methods
-(void)parsingBusStops
{
    NSURL *url = [NSURL URLWithString:@"http://www.bayareabikeshare.com/stations/json"];

    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];

    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue]  completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         NSDictionary *busStopDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
         self.rawStationsArray = [busStopDictionary objectForKey:@"stationBeanList"];
         self.temporaryArray = [NSMutableArray new];


         for (NSDictionary *station in self.rawStationsArray)
         {
             Station *currentStation = [Station new];

             currentStation.latitude = [station objectForKey:@"latitude"];
             currentStation.longitude = [station objectForKey:@"longitude"];

             currentStation.name  = [station objectForKey:@"stAddress1"];

             currentStation.availableBikes = [[station objectForKey:@"availableBikes"] longValue];

             currentStation.userCurrentLocation = self.currentLocation;

             [self.temporaryArray addObject:currentStation];
         }
         [self sortArray];
         [self.tableView reloadData];
     }];
}

-(void)sortArray
{
    for (Station *station in self.temporaryArray)
    {
        CLLocationDegrees latitude = [station.latitude doubleValue];
        CLLocationDegrees longitude = [station.longitude doubleValue];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        CLLocationDistance metersAway = [self.currentLocation distanceFromLocation:location];
        station.metersAway = metersAway;
    }
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"metersAway" ascending:true];
    NSArray *sortedArray = [self.temporaryArray sortedArrayUsingDescriptors:@[sortDescriptor]];
    self.stations = [NSMutableArray arrayWithArray:sortedArray];
    self.searchedStations = self.stations;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MapViewController *mapVC = [segue destinationViewController];
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    mapVC.station = [self.stations objectAtIndex:selectedIndexPath.row];
}

@end
