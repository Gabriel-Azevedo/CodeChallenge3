//
//  Station.h
//  CodeChallenge3
//
//  Created by Gabriel Borri de Azevedo on 1/23/15.
//  Copyright (c) 2015 Mobile Makers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Station : NSObject

@property NSString *name;
@property NSString *latitude;
@property NSString *longitude;
@property long availableBikes;
@property CLLocation *userCurrentLocation;
@property float metersAway;

@end
