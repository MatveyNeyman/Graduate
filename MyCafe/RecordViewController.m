//
//  RecordViewController.m
//  MyCafe
//
//  Created by User on 12/18/15.
//  Copyright © 2015 Harman. All rights reserved.
//

#import "RecordViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "SharedData.h"

@interface RecordViewController () <CLLocationManagerDelegate, MKMapViewDelegate>
{
    CGFloat iconSize;
    UIView *mainView;
}

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *typeLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIView *photosView;
@property (strong, nonatomic) IBOutlet UITextView *notesView;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLGeocoder *geocoder;
@property (strong, nonatomic) CLLocation *location;

@end

@implementation RecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Setup icons size
    iconSize = 18;
    // Recognize the view to add icons
    mainView = [self.view viewWithTag:2];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    
    //[self showRecordLocation:self.location];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.nameLabel.text = self.record.name;
    self.typeLabel.text = self.record.type;
    
    // Check wether address is not set
    if ([self.record.address isEqualToString:@""]) {
        // Check address availability in order to stay active constraints between addreess field and map
        self.addressLabel.text = @" ";
        self.distanceLabel.text = @" ";
    } else {
        self.addressLabel.text = self.record.address;
    }
    
    [self addRatingAndPriceIcons];
    self.notesView.text = self.record.notes;
    
    [self getLocationFromAddress];
}

- (void)addRatingAndPriceIcons {
    for (int i = 0; i < self.record.rating; i++) {
        CGFloat originY = mainView.frame.origin.y + 10;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(8 + iconSize * i, originY, iconSize, iconSize)];
        imageView.image = [UIImage imageNamed:@"filledStar"];
        [mainView addSubview:imageView];
    }
    for (int i = 0; i < self.record.price; i++) {
        CGFloat originY = mainView.frame.origin.y + 10 + iconSize + 10;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(8 + iconSize * i, originY, iconSize, iconSize)];
        imageView.image = [UIImage imageNamed:@"filledCoin"];
        [mainView addSubview:imageView];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)getLocationFromAddress {
    // Initialize Geocoder object to get coordinates from location address (forward geocoding)
    if (!self.geocoder) {
        self.geocoder = [[CLGeocoder alloc] init];
    }
    if (self.record.location) {
        self.location = self.record.location;
        [self showRecordLocation:self.record.location];
    } else {
        [self.geocoder geocodeAddressString:self.record.address
                          completionHandler:^(NSArray<CLPlacemark *> *placemarks, NSError *error) {
                              if ([placemarks count] > 0) {
                                  CLPlacemark *currentPlacemark = [placemarks objectAtIndex:0];
                                  self.location = currentPlacemark.location;
                                  NSLog(@"Record Location: %@", self.location);
                                  [self showRecordLocation:self.location];
                              }
        }];
    }
}

- (void)showRecordLocation:(CLLocation *)location {
    //NSLog(@"Location coordinate: %@", location.coordinate);
    MKCoordinateRegion coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 800, 800);
    [self.mapView setRegion:coordinateRegion animated:YES];
    [self makeAnnotation];
}

- (void)makeAnnotation {
    MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
    pin.coordinate = self.location.coordinate;
    //NSLog(@"Pin coordinates: %@", pin.coordinate.latitude);
    pin.title = self.record.name;
    pin.subtitle = self.record.type;
    [self.mapView addAnnotation:pin];
}


#pragma mark - MKMapViewDelegate

- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    MKPinAnnotationView *aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    aView.canShowCallout = YES;
    return aView;
}

- (IBAction)temporaryRemoveAction:(id)sender {
    [[SharedData sharedData] removeRecord:self.record];
}

@end
