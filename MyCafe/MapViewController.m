//
//  MapViewController.m
//  MyCafe
//
//  Created by User on 11/19/15.
//  Copyright © 2015 Harman. All rights reserved.
//

#import "MapViewController.h"

//CLLocationManager *locationManager;

@interface MapViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet UIButton *showMyLocation;

@end

@implementation MapViewController


- (void)awakeFromNib {
    NSLog(@"MapView awaked from nib");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"MapView loaded");
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    
    //self.mapView.delegate = self;
    
    CLLocation *currentLocation = self.locationManager.location;
    [self initialMapState:currentLocation];
    
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"MapView appeared");
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
/*
- (void)startSignificantChangeUpdates {
    // Create the location manager if this object does not already have one.
    if (nil == self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    self.locationManager.delegate = self;
    [self.locationManager startMonitoringSignificantLocationChanges];
}

- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    return NULL;
}
*/
/*
- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView {
    NSLog(@"mapViewWillStartLoadingMap");
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
}
*/

-(void)initialMapState:(CLLocation *)locationParameter {
    MKCoordinateRegion coordinateRegion = MKCoordinateRegionMakeWithDistance(locationParameter.coordinate, 2000, 2000);
    [self.mapView setRegion:coordinateRegion animated:YES];
}

- (IBAction)showMyLocationPressed:(id)sender {
    CLLocationCoordinate2D currentLocationCoordinate = self.locationManager.location.coordinate;
    [self.mapView setCenterCoordinate:currentLocationCoordinate animated:YES];
}

@end
