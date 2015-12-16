//
//  NewRecordViewController.m
//  MyCafe
//
//  Created by User on 12/10/15.
//  Copyright © 2015 Harman. All rights reserved.
//

#import "CreateRecordViewController.h"
#import "TypeSelectorViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <HCSStarRatingView/HCSStarRatingView.h>

@interface CreateRecordViewController () <CLLocationManagerDelegate,
                                        UINavigationControllerDelegate, UIImagePickerControllerDelegate> // Both needed for image picker
{
    CGFloat pos; // Start position for the first photo
    CGFloat gap; // Gap between photos and leading margin for the first photo
}

@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (strong, nonatomic) IBOutlet UITableView *createRecordTableView;

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;

@property (strong, nonatomic) IBOutlet UILabel *typeLabel;

@property (strong, nonatomic) IBOutlet UITextField *addressTextField;

@property (strong, nonatomic) IBOutlet UISwitch *useCurrentLocationSwitch;

@property (strong, nonatomic) IBOutlet UIButton *oneStarButton;
@property (strong, nonatomic) IBOutlet UIButton *twoStarsButton;
@property (strong, nonatomic) IBOutlet UIButton *threeStarsButton;
@property (strong, nonatomic) IBOutlet UIButton *fourStarsButton;
@property (strong, nonatomic) IBOutlet UIButton *fiveStarsButton;

@property (strong, nonatomic) IBOutlet UIButton *oneBuckButton;
@property (strong, nonatomic) IBOutlet UIButton *twoBucksButton;
@property (strong, nonatomic) IBOutlet UIButton *threeBucksButton;
@property (strong, nonatomic) IBOutlet UIButton *fourBucksButton;
@property (strong, nonatomic) IBOutlet UIButton *fiveBucksButton;

@property (strong, nonatomic) IBOutlet UIButton *addPhotoButton;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollPhotosView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@property (nonatomic) TypeSelectorViewController *typeSelectorViewController;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLGeocoder *geocoder;

@end


@implementation CreateRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"New Record loaded");
    self.selectedType = @"Restaurant";
    pos = 0;
    gap = 10;
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.typeSelectorViewController.currentType) {
        self.selectedType = self.typeSelectorViewController.currentType;
    }
    self.typeLabel.text = self.selectedType;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    self.typeSelectorViewController = segue.destinationViewController;
    self.typeSelectorViewController.currentType = self.selectedType;
    NSLog(@"Current Type in prepare for segue: %@", self.typeSelectorViewController.currentType);
}

- (IBAction)cancelButtonClicked:(id)sender {
    NSLog(@"New Record cancelled");
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doneButtonClicked:(id)sender {
    
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001;
}

- (IBAction)useCurrentLocationSwitchTriggered:(id)sender {
    NSLog(@"Current Location Switch Triggered");
    UISwitch *switcher = (UISwitch *) sender;
    if (switcher.isOn) {
        NSLog(@"Switch is ON");
        [self feedAddress];
    } else {
        NSLog(@"Switch is OFF");
        self.addressTextField.text = nil;
    }
}

- (void)feedAddress {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    
    CLLocation *currentLocation = self.locationManager.location;
    
    // Initialize Geocoder object to get address from location coordinates (reverse geocoding)
    if (!self.geocoder) {
        self.geocoder = [[CLGeocoder alloc] init];
    }
    
    [self.geocoder reverseGeocodeLocation:currentLocation completionHandler:
     ^(NSArray<CLPlacemark *> *placemarks, NSError *error) {
         if ([placemarks count] > 0) {
             CLPlacemark *currentPlacemark = [placemarks objectAtIndex:0];
             
             // placemarks array contains addressDictionary dictionary with tge following array as one of the values
             NSArray *currentAddressArray = [currentPlacemark.addressDictionary objectForKey:@"FormattedAddressLines"];
             
             // Navigate array and build final address
             NSString *currentAddress = @"";
             for (int i = 0; i < currentAddressArray.count; i++) {
                 NSString *str = currentAddressArray[i];
                 currentAddress = [currentAddress stringByAppendingString:str];
                 if (i >= 0 && i < currentAddressArray.count - 1) {
                     currentAddress = [currentAddress stringByAppendingString:@", "];
                 }
             }
             // Feed address field
             self.addressTextField.text = currentAddress;
         }
     }];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell.reuseIdentifier isEqual:@"Rating"]) {
        NSLog(@"Rating cell found");
        [self createStarRatingViewForCell:cell
                      withEmptyImageNamed:@"emptyStar"
                     withFilledImageNamed:@"filledStar"
                                   action:@selector(didChangeRating:)];
    }
    if ([cell.reuseIdentifier isEqual:@"Price"]) {
        NSLog(@"Price cell found");
        [self createStarRatingViewForCell:cell
                      withEmptyImageNamed:@"emptyCoin"
                     withFilledImageNamed:@"filledCoin"
                                   action:@selector(didChangePrice:)];
    }
}

- (void)createStarRatingViewForCell:(UITableViewCell *)cell
                     withEmptyImageNamed:(NSString *)emptyImage
               withFilledImageNamed:(NSString *)filledImage
                             action:(SEL)action {
    HCSStarRatingView *starRatingView = [[HCSStarRatingView alloc] init];
    starRatingView.maximumValue = 5;
    starRatingView.minimumValue = 0;
    starRatingView.value = 0;
    starRatingView.emptyStarImage = [UIImage imageNamed:emptyImage];
    starRatingView.filledStarImage = [UIImage imageNamed:filledImage];
    [starRatingView addTarget:self action:action forControlEvents:UIControlEventValueChanged];
    [cell.contentView addSubview:starRatingView];
    starRatingView.translatesAutoresizingMaskIntoConstraints = NO;
    [[NSLayoutConstraint constraintWithItem:starRatingView
                                  attribute:NSLayoutAttributeCenterY
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:cell.contentView
                                  attribute:NSLayoutAttributeCenterY
                                 multiplier:1
                                   constant:0] setActive:YES];
    [[NSLayoutConstraint constraintWithItem:cell.contentView
                                  attribute:NSLayoutAttributeTrailingMargin
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:starRatingView
                                  attribute:NSLayoutAttributeTrailing
                                 multiplier:1
                                   constant:10] setActive:YES];
    [[NSLayoutConstraint constraintWithItem:starRatingView
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:1
                                   constant:28] setActive:YES];
    [[NSLayoutConstraint constraintWithItem:starRatingView
                                  attribute:NSLayoutAttributeWidth
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:1
                                   constant:180] setActive:YES];
}

- (IBAction)didChangeRating:(HCSStarRatingView *)sender {
    NSLog(@"Changed rating to %.1f", sender.value);
}

- (IBAction)didChangePrice:(HCSStarRatingView *)sender {
    NSLog(@"Changed price to %.1f", sender.value);
}

- (IBAction)addPhoto:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    // If the device has a camera, take a picture, otherwise, just pick from photo library
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

// Dealing with taken picture
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
    CGFloat ratio = image.size.height / image.size.width; // Aspect ratio for taken/choosen image
    CGFloat imageWidth;     // Placeholder's width
    CGFloat imageHeight;    // Placeholder's height
    CGFloat originY;        // Placeholder's center point
    
    // Check portrait or landscape view
    if (ratio >= 1) {
        imageWidth = 70 / ratio;
        imageHeight = 70;
    } else {
        imageWidth = 70;
        imageHeight = 70 * ratio;
    }
    originY = (self.scrollPhotosView.frame.size.height - imageHeight) / 2;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(pos + gap, originY, imageWidth, imageHeight)];

    imageView.image = image;
    [self.scrollPhotosView addSubview:imageView];
    
    /*
    [[NSLayoutConstraint constraintWithItem:imageView
                                  attribute:NSLayoutAttributeCenterY
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.scrollPhotosView
                                  attribute:NSLayoutAttributeCenterY
                                 multiplier:1
                                   constant:0] setActive:YES];
    [[NSLayoutConstraint constraintWithItem:self.scrollPhotosView
                                  attribute:NSLayoutAttributeLeadingMargin
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:imageView
                                  attribute:NSLayoutAttributeLeadingMargin
                                 multiplier:1
                                   constant:0] setActive:YES];
    
    [[NSLayoutConstraint constraintWithItem:imageView
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:1
                                   constant:69] setActive:YES];
     
    [[NSLayoutConstraint constraintWithItem:imageView
                                  attribute:NSLayoutAttributeWidth
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:1
                                   constant:45] setActive:YES];
     */
    
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = self.addPhotoButton.frame;
        frame.origin.x = self.addPhotoButton.frame.origin.x + imageWidth + gap;
        pos += imageWidth + gap;
        self.addPhotoButton.translatesAutoresizingMaskIntoConstraints = YES;
        self.addPhotoButton.frame = frame;
    }];
    
}




@end
