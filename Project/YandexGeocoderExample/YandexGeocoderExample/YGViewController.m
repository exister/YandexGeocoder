//
//  YGViewController.m
//  YandexGeocoderExample
//
//  Created by Mikhail Kuznetsov on 29.12.12.
//  Copyright (c) 2012 mkuznetsov. All rights reserved.
//

#import "YGViewController.h"

@interface YGViewController ()

@property(nonatomic, strong) CLLocationManager *manager;

@end

@implementation YGViewController

@synthesize query, console;
@synthesize manager = _manager;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.manager = [[CLLocationManager alloc] init];
    self.manager.delegate = self;
    self.manager.desiredAccuracy = kCLLocationAccuracyBest;
    self.manager.distanceFilter = 5.0;
    self.manager.headingFilter = 30.0;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[YandexGeocoder sharedInstance] cancelAllRequestsForDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onPositionToLocations:(id)sender {
    [self.manager startUpdatingLocation];
}

- (void)yandexGeocoderRequestFinished:(NSDictionary *)places
{
    self.console.text = places.description;
}

- (void)yandexGeocoderRequestFailed
{
    self.console.text = @"Geocoding failed";
}

- (IBAction)onQueryToLocations:(id)sender {
    [self.query resignFirstResponder];
    [[YandexGeocoder sharedInstance] forwardGeocoding:self.query.text success:^(AFHTTPRequestOperation *operation, id responseObject, NSDictionary *places) {
        [self yandexGeocoderRequestFinished:places];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self yandexGeocoderRequestFailed];
    } owner:self];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = locations[0];
    [[YandexGeocoder sharedInstance] reversedGeocodingForLatitude:location.coordinate.latitude longitude:location.coordinate.longitude language:@"EN" kind:@"house" success:^(AFHTTPRequestOperation *operation, id responseObject, NSDictionary *places) {
        [self yandexGeocoderRequestFinished:places];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self yandexGeocoderRequestFailed];
    } owner:self];
}
@end
