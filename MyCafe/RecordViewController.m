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
#import "PhotosStore.h"
#import "CreateRecordViewController.h"
#import "ImageViewController.h"
@import GoogleMaps;
#import <Parse/Parse.h>

@interface RecordViewController () <CLLocationManagerDelegate, /*MKMapViewDelegate,*/ GMSMapViewDelegate>
{
    CGFloat iconSize;
    UIView *mainView;
    CGFloat pos; // Start position for the first photo
    CGFloat gap; // Gap between photos and leading margin for the first photo
    BOOL isExistOnServer;
}

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *typeLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIView *photosView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *photosViewWidthEqualConstraint;
@property (strong, nonatomic) IBOutlet UITextView *notesView;
@property (strong, nonatomic) IBOutlet GMSMapView *googleMapView;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
//@property (strong, nonatomic) CLGeocoder *geocoder;
@property (nonatomic) CreateRecordViewController *createRecordViewController;
@property (nonatomic) NSMutableDictionary<NSNumber *, NSString *> *tagPhotoKey;

@end

@implementation RecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Setup icons size
    iconSize = 18.0f;
    // Setup variables for positioning image gallery
    pos = 8.0f;
    gap = 10.0f;
    
    // Recognize the view to add icons
    mainView = [self.view viewWithTag:2];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    self.currentLocation = self.locationManager.location;
    
    [self showRecordLocation:self.record.location];
    
    self.nameLabel.text = self.record.name;
    self.typeLabel.text = self.record.type;
    
    // Check whether address is not set
    if ([self.record.address isEqualToString:@""]) {
        // Check address availability in order to stay active constraints between addreess field and map
        self.addressLabel.text = @" ";
        self.distanceLabel.text = @" ";
    } else {
        self.addressLabel.text = self.record.address;
    }
    
    [self addRatingAndPriceIcons];
    [self addImages];
    
    self.notesView.text = self.record.notes;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    /*
    self.nameLabel.text = self.record.name;
    self.typeLabel.text = self.record.type;
    
    // Check whether address is not set
    if ([self.record.address isEqualToString:@""]) {
        // Check address availability in order to stay active constraints between addreess field and map
        self.addressLabel.text = @" ";
        self.distanceLabel.text = @" ";
    } else {
        self.addressLabel.text = self.record.address;
    }
    
    [self addRatingAndPriceIcons];
    [self addImages];
    
    self.notesView.text = self.record.notes;
    */
    
    /*
    if (self.record.location) {
        CLLocationDistance distance = [self.record.location distanceFromLocation:self.currentLocation];
        if (distance > 0 && distance <= 950) {
            NSInteger roundedDistanceTo50 = (NSInteger)ceil(distance / 50) * 50;
            self.distanceLabel.text = [NSString stringWithFormat:@"%ld m", (long)roundedDistanceTo50];
        }
        if (distance > 950 && distance <= 9900) {
            double roundedDistanceTo100 = (NSInteger)ceil(distance / 100);
            roundedDistanceTo100 = roundedDistanceTo100 * 100 / 1000;
            self.distanceLabel.text = [NSString stringWithFormat:@"%.1f km", roundedDistanceTo100];
        }
        if (distance > 9900) {
            NSInteger roundedDistanceTo1000 = (NSInteger)ceil(distance / 1000);
            self.distanceLabel.text = [NSString stringWithFormat:@"%ld km", (long)roundedDistanceTo1000];
        }
    } else {
        self.distanceLabel.text = @"";
    }
    */
    
    self.distanceLabel.text = [[SharedData sharedData] distanceToRecord:self.record];
    
    //CLLocationDistance distance = [self.record.location distanceFromLocation:self.currentLocation];
    //self.distanceLabel.text = [NSString stringWithFormat:@"%.0f m", distance];
    
    //[self showRecordLocation:self.record.location];
}

- (void)addRatingAndPriceIcons {
    for (int i = 0; i < self.record.rating; i++) {
        CGFloat originY = mainView.frame.origin.y + 10.0f;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(8.0f + iconSize * i, originY, iconSize, iconSize)];
        imageView.image = [UIImage imageNamed:@"filledStar"];
        [mainView addSubview:imageView];
    }
    for (int i = 0; i < self.record.price; i++) {
        CGFloat originY = mainView.frame.origin.y + 10.0f + iconSize + 10.0f;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(8.0f + iconSize * i, originY, iconSize, iconSize)];
        imageView.image = [UIImage imageNamed:@"filledCoin"];
        [mainView addSubview:imageView];
    }
}

- (void)showRecordLocation:(CLLocation *)location {
    /*
    //NSLog(@"Location coordinate: %@", location.coordinate);
    MKCoordinateRegion coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 800, 800);
    [self.mapView setRegion:coordinateRegion animated:YES];
    //[self makeAnnotation:location];
    MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
    pin.coordinate = location.coordinate;
    //NSLog(@"Pin coordinates: %@", pin.coordinate.latitude);
    pin.title = self.record.name;
    pin.subtitle = self.record.type;
    [self.mapView addAnnotation:pin];
    */
    
    CLLocationCoordinate2D target = location.coordinate;
    self.googleMapView.camera = [GMSCameraPosition cameraWithTarget:target zoom:15];
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = location.coordinate;
    marker.map = self.googleMapView;
}

/*
#pragma mark - MKMapViewDelegate

- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    MKPinAnnotationView *aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    aView.canShowCallout = YES;
    return aView;
}
*/

- (IBAction)editButtonClicked:(id)sender {
    self.createRecordViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateRecordViewController"];
    self.createRecordViewController.isEditingMode =  YES;
    self.createRecordViewController.navigationItem.title = nil;
    self.createRecordViewController.record = self.record;
    [self.navigationController pushViewController:self.createRecordViewController animated:NO];
}

- (void)addImages {
    for (NSString *key in self.record.photosKeys) {
        UIImage *image = [[PhotosStore photosStore] imageForKey:key];
        CGFloat aspectRatio = image.size.height / image.size.width; // Aspect ratio for taken/choosen image
        CGFloat thumbnailWidth;     // Placeholder's width
        CGFloat thumbnailHeight;    // Placeholder's height
        CGFloat originY;            // Placeholder's center point
        
        // Check portrait or landscape view
        if (aspectRatio >= 1.0f) {
            // Portrait
            thumbnailWidth = 118.0f / aspectRatio;
            thumbnailHeight = 118.0f;
        } else {
            // Landscape
            thumbnailWidth = 118.0f;
            thumbnailHeight = 118.0f * aspectRatio;
        }
        // Create the ImageView for thumbnails
        originY = (self.photosView.frame.size.height - thumbnailHeight) / 2.0f;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(pos, originY, thumbnailWidth, thumbnailHeight)];
        
        imageView.userInteractionEnabled = YES;
        
        imageView.tag = pos;
        NSNumber *tag = @(imageView.tag);
        
        if (!self.tagPhotoKey) {
            self.tagPhotoKey = [[NSMutableDictionary alloc] init];
        }
        self.tagPhotoKey[tag] = key;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)];
        tap.numberOfTapsRequired = 1;
        
        [imageView addGestureRecognizer:tap];
        
        // Resize the image
        CGSize thumbnailSize;
        thumbnailSize.width = thumbnailWidth;
        thumbnailSize.height = thumbnailHeight;
        UIGraphicsBeginImageContextWithOptions(thumbnailSize, NO, 0.0f);
        [image drawInRect:CGRectMake(0.0f, 0.0f, thumbnailWidth, thumbnailHeight)];
        UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        // Setup view's image using resized image
        imageView.image = thumbnail;
        
        pos += thumbnailWidth + gap;

        // Resize photosView via modifying constraint initially set to zero
        self.photosViewWidthEqualConstraint.constant = pos;

        [self.photosView addSubview:imageView];
        
        NSLog(@"self.record.photosKeys %@", self.record.photosKeys);
    }
}

- (void)tapImage:(UIGestureRecognizer *)gestureRecognizer {
    NSLog(@"self.record.photosKeys %@", self.record.photosKeys);
    UIImageView *imageView = (UIImageView *)gestureRecognizer.view;
    NSInteger intTag = imageView.tag;
    NSNumber *tag = @(intTag);
    NSString *key = self.tagPhotoKey[tag];
    
    //UIImage *image = [[PhotosStore photosStore] imageForKey:key];
    
    ImageViewController *ivc = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageViewController"];
    //ivc.image = image;
    ivc.photosKeys = self.record.photosKeys;
    ivc.startKey = key;
    [self.navigationController pushViewController:ivc animated:YES];
}

- (IBAction)shareClicked:(id)sender {
    NSLog(@" share Record button clicked");
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *shareAction = [UIAlertAction actionWithTitle:@"Upload to server"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction *action) {
                                                                [self sendToParseCom];
                                                            }];
    [alert addAction:shareAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {}];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)sendToParseCom {
    if ([self isAlreadyExist] == NO) {
        PFObject *recordObject = [PFObject objectWithClassName:@"RecordObject"];
        double latitude = self.record.location.coordinate.latitude;
        double longitude = self.record.location.coordinate.longitude;
        PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:latitude longitude:longitude];
        
        // Initialize CLLocation property of the Record in the following way:
        //CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        
        recordObject[@"name"] = self.record.name;
        recordObject[@"type"] = self.record.type;
        recordObject[@"address"] = self.record.address;
        recordObject[@"point"] = point;
        recordObject[@"rating"] = @(self.record.rating);
        recordObject[@"price"] = @(self.record.price);
        recordObject[@"photosKeys"] = self.record.photosKeys;
        recordObject[@"notes"] = self.record.notes;
        [recordObject saveInBackground];
        
        for (NSString *key in self.record.photosKeys) {
            PFObject *photoObject = [PFObject objectWithClassName:@"PhotoObject"];
            UIImage *image = [[PhotosStore photosStore] imageForKey:key];
            NSData *imageData = UIImagePNGRepresentation(image);
            PFFile *imageFile = [PFFile fileWithName:key data:imageData];
            photoObject[@"photoName"] = key;
            photoObject[@"photoFile"] = imageFile;
            [photoObject saveInBackground];
        }
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Record has been succesfully uploaded"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {}];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)isAlreadyExist {
    isExistOnServer = NO;
    
    double latitude = self.record.location.coordinate.latitude;
    double longitude = self.record.location.coordinate.longitude;
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:latitude longitude:longitude];
    
    PFQuery *query = [PFQuery queryWithClassName:@"RecordObject"];
    [query whereKey:@"name" equalTo:self.record.name];
    //[query whereKey:@"type" equalTo:self.record.type];
    //[query whereKey:@"address" equalTo:self.record.address];
    [query whereKey:@"point" equalTo:point];
    //[query whereKey:@"rating" equalTo:@(self.record.rating)];
    //[query whereKey:@"price" equalTo:@(self.record.price)];
                    //[query whereKey:@"photosKeys" equalTo:self.record.photosKeys];
    //[query whereKey:@"notes" equalTo:self.record.notes];
    
    NSArray* scoreArray = [query findObjects];
    if ([scoreArray count] > 0) {
        //for (PFObject *object in scoreArray) {
            //if ([object[@"photosKeys"] isEqualToArray:self.record.photosKeys]) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"This record is already exists on server"
                                                                               message:nil
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                        style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction *action) {}];
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
                isExistOnServer = YES;
            //}
        //}
    } else {
        isExistOnServer = NO;
    }
    return isExistOnServer;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
