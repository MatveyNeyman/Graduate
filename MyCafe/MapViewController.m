//
//  MapViewController.m
//  MyCafe
//
//  Created by User on 11/19/15.
//  Copyright © 2015 Harman. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "SharedData.h"
#import "RecordAnnotation.h"
#import "RecordViewController.h"
@import GoogleMaps;
#import "SMCalloutView.h"



//CLLocationManager *locationManager;

@interface MapViewController () <CLLocationManagerDelegate, /*MKMapViewDelegate,*/ GMSMapViewDelegate, SMCalloutViewDelegate> {
    GMSMapView *mapView_;
    CGFloat CalloutYOffset;
    CGFloat iconSize;
}

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIButton *showMyLocation;

@property (nonatomic) NSArray<Record *> *records;

//@property (nonatomic) NSArray<MKPointAnnotation *> *pins;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) RecordViewController *recordViewController;

@property (strong, nonatomic) SMCalloutView *calloutView;
@property (strong, nonatomic) UIView *emptyCalloutView;

@end


@implementation MapViewController

- (void)awakeFromNib {
    NSLog(@"MapView awaked from nib");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"MapView loaded");
    
    CalloutYOffset = 40.0f;
    iconSize = 12.0f;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    
    /*
    self.mapView.delegate = self;
    CLLocation *currentLocation = self.locationManager.location;
    [self initialMapState:currentLocation];
    */
    
    //Google Map starts here
    CLLocationCoordinate2D target = self.locationManager.location.coordinate;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:target zoom:10];
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_.myLocationEnabled = YES;
    mapView_.settings.myLocationButton = YES;
    mapView_.delegate = self;
    self.view = mapView_;
    
    self.calloutView = [[SMCalloutView alloc] init];
    self.emptyCalloutView = [[UIView alloc] initWithFrame:CGRectZero];
    self.calloutView.delegate = self;
   
    UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [button addTarget:self
               action:@selector(calloutViewClicked:)
     forControlEvents:UIControlEventTouchUpInside];
    self.calloutView.rightAccessoryView = button;
    
    [self registerOrientationNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Initializing SharedData singleton and array with records
    self.records = [SharedData sharedData].listOfRecords;
    
    /*
    // Apple Map annotations
    NSMutableArray<MKPointAnnotation *> *pins = [NSMutableArray arrayWithCapacity:self.records.count];
    for (Record *record in self.records) {
        RecordAnnotation *pin = [[RecordAnnotation alloc] init];
        pin.record = record;
        pin.coordinate = record.location.coordinate;
        pin.title = record.name;
        pin.subtitle = record.type;
        [pins addObject:pin];
    }
    [self.mapView addAnnotations:pins];
    */
     
    // Google Map markers
    for (Record *record in self.records) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = record.location.coordinate;
        NSLog(@"Marker position: %f %f", marker.position.latitude, marker.position.longitude);
        marker.title = record.name;
        marker.snippet = record.type;
        marker.map = mapView_;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"MapView appeared");
    // We have to update the infoWindow if user left the view then rotated device and came back 
    [self updateInfoWindow];
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

/*
-(void)initialMapState:(CLLocation *)locationParameter {
    MKCoordinateRegion coordinateRegion = MKCoordinateRegionMakeWithDistance(locationParameter.coordinate, 2000, 2000);
    [self.mapView setRegion:coordinateRegion animated:YES];
}

// Centers map on the current location along with set parameters
- (IBAction)showMyLocationClicked:(id)sender {
    CLLocationCoordinate2D currentLocationCoordinate = self.locationManager.location.coordinate;
    [self.mapView setCenterCoordinate:currentLocationCoordinate animated:YES];
}

#pragma mark - MKMapViewDelegate

- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    // If the annotation is the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;   
    }
    if ([annotation isKindOfClass:[RecordAnnotation class]]) {
        // Try to dequeue an existing pin view first.
        MKPinAnnotationView *pinView = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:@"PinAnnotationView"];
        
        if (!pinView) {
            // If an existing pin view was not available, create one.
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"PinAnnotationView"];
            
            //pinView.pinColor = MKPinAnnotationColorRed;
            //pinView.animatesDrop = YES;
            pinView.canShowCallout = YES;
            
            // Add the detail disclosure button to display details about the annotation in another view.
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            pinView.rightCalloutAccessoryView = rightButton;
            
        } else {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    NSLog(@"calloutAccessoryControlTapped");
    RecordAnnotation *pin = view.annotation;
    NSLog(@"Record: %@", pin.record);
    self.recordViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RecordViewController"];
    self.recordViewController.record = pin.record;
    [self.navigationController pushViewController:self.recordViewController animated:YES];
}
*/


#pragma mark - GMSMapViewDelegate

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    
    CLLocationCoordinate2D anchor = marker.position;
 
    CGPoint point = [mapView.projection pointForCoordinate:anchor];
 
    self.calloutView.title = marker.title;
    self.calloutView.subtitle = marker.snippet;
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectZero];
    //leftView.backgroundColor = [UIColor colorWithRed:0 green:0.5 blue:1 alpha:1];
    Record *recordForMarker = [self recordForMarker:marker];
    for (int i = 0; i < recordForMarker.rating; i++) {
        CGFloat originY = 10.0f;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(8.0f + iconSize * i, originY, iconSize, iconSize)];
        imageView.image = [UIImage imageNamed:@"filledStar"];
        [leftView addSubview:imageView];
    }
    for (int i = 0; i < recordForMarker.price; i++) {
        CGFloat originY = 30.0f;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(8.0f + iconSize * i, originY, iconSize, iconSize)];
        imageView.image = [UIImage imageNamed:@"filledCoin"];
        [leftView addSubview:imageView];
    }
    
    leftView.frame = CGRectMake(0.0f, 0.0f, iconSize * MAX(recordForMarker.rating, recordForMarker.price) + 16.0f, 52.0f);
    self.calloutView.leftAccessoryView = leftView;
    
    self.calloutView.calloutOffset = CGPointMake(0.0f, -CalloutYOffset);
    self.calloutView.hidden = NO;
 
    CGRect calloutRect = CGRectZero;
    calloutRect.origin = point;
    calloutRect.size = CGSizeZero;
 
    [self.calloutView presentCalloutFromRect:calloutRect
                                      inView:mapView
                           constrainedToView:mapView
                                    animated:YES];
 
    return self.emptyCalloutView;
}

- (void)mapView:(GMSMapView *)pMapView didChangeCameraPosition:(GMSCameraPosition *)position {
    [self updateInfoWindow];
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    self.calloutView.hidden = YES;
}


#pragma mark - SMCalloutViewDelegate

- (void)calloutViewClicked:(SMCalloutView *)calloutView {
    if (mapView_.selectedMarker) {
        GMSMarker *marker = mapView_.selectedMarker;
        self.recordViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RecordViewController"];
        self.recordViewController.record = [self recordForMarker:marker];
        [self.navigationController pushViewController:self.recordViewController animated:YES];
    }
}


#pragma mark - Update infoWindow after orientation changed

// Called in view controller setup code.
- (void)registerOrientationNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateInfoWindow)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)updateInfoWindow {
    // Move callout with map drag or orientation change
    if (mapView_.selectedMarker != nil && !self.calloutView.hidden) {
        CLLocationCoordinate2D anchor = mapView_.selectedMarker.position;
        CGPoint arrowPt = self.calloutView.backgroundView.arrowPoint;
        CGPoint pt = [mapView_.projection pointForCoordinate:anchor];
        pt.x -= arrowPt.x;
        pt.y -= arrowPt.y + CalloutYOffset;
        self.calloutView.frame = (CGRect) {.origin = pt, .size = self.calloutView.frame.size };
    } else {
        self.calloutView.hidden = YES;
    }
}

/*
- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    CLLocationCoordinate2D markerCoordinate = marker.position;
    for (Record *record in self.records) {
        CLLocationCoordinate2D recordCoordinate = record.location.coordinate;
        if (recordCoordinate.latitude == markerCoordinate.latitude &&
                recordCoordinate.longitude == markerCoordinate.longitude &&
                record.name == marker.title && record.type == marker.snippet) {
            self.recordViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RecordViewController"];
            self.recordViewController.record = record;
            [self.navigationController pushViewController:self.recordViewController animated:YES];
            return;
        }
    }
}
*/

- (Record *)recordForMarker:(GMSMarker *)marker {
    CLLocationCoordinate2D markerCoordinate = marker.position;
    for (Record *record in self.records) {
        CLLocationCoordinate2D recordCoordinate = record.location.coordinate;
        if (recordCoordinate.latitude == markerCoordinate.latitude &&
            recordCoordinate.longitude == markerCoordinate.longitude &&
            record.name == marker.title && record.type == marker.snippet) {
            return record;
        }
    }
    return nil;
}

@end
