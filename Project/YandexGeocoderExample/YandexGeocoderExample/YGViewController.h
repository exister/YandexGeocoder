//
//  YGViewController.h
//  YandexGeocoderExample
//
//  Created by Mikhail Kuznetsov on 29.12.12.
//  Copyright (c) 2012 mkuznetsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "YandexGeocoder.h"

@interface YGViewController : UIViewController <YandexGeocoderDelegate, CLLocationManagerDelegate>

- (IBAction)onQueryToLocations:(id)sender;
- (IBAction)onPositionToLocations:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *query;
@property (strong, nonatomic) IBOutlet UITextView *console;
@end
