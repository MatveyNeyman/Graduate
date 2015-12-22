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
#import "Record.h"
#import "SharedData.h"

@interface CreateRecordViewController () <CLLocationManagerDelegate,
                                        UINavigationControllerDelegate, UIImagePickerControllerDelegate> // Both needed for image picker
{
    CGFloat pos; // Start position for the first photo
    CGFloat gap; // Gap between photos and leading margin for the first photo
    UIView *activeField;
    UIEdgeInsets currentInsets;
}

@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (strong, nonatomic) IBOutlet UITableView *createRecordTableView;

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;

@property (strong, nonatomic) IBOutlet UILabel *typeLabel;

@property (strong, nonatomic) IBOutlet UITextField *addressTextField;

@property (strong, nonatomic) IBOutlet UISwitch *useCurrentLocationSwitch;

@property (strong, nonatomic) IBOutlet UIButton *addPhotoButton;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollPhotosView;
@property (strong, nonatomic) IBOutlet UITextView *notesTextView;

@property (nonatomic) TypeSelectorViewController *typeSelectorViewController;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLGeocoder *geocoder;

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *type;
@property (nonatomic) NSString *address;
@property (nonatomic) CLLocation *location;
@property (nonatomic) NSInteger rating;
@property (nonatomic) NSInteger price;
@property (nonatomic) NSMutableArray<UIImage *> *photos;
@property (nonatomic) NSString *notes;

@end


@implementation CreateRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //NSLog(@"New Record loaded");
    self.selectedType = @"Restaurant";
    pos = 0;
    gap = 10;
    [self registerForKeyboardNotifications];
    self.photos = [[NSMutableArray alloc] init];
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
    self.name = self.nameTextField.text;
    self.type = self.selectedType;
    self.address = self.addressTextField.text;
    self.notes = self.notesTextView.text;

    // Checking for empty name and showing an alert message if it is
    if ([[self.name stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Please input name of the place"
                                                               message:nil
                                                        preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    
    // Creating new Record object initialized by the corresponding properties and adding it to the array
    Record *newRecord = [[Record alloc] initWithName:self.name
                                                type:self.type
                                             address:self.address
                                            location:self.location
                                              rating:self.rating
                                               price:self.price
                                              photos:self.photos
                                               notes:self.notes];
    NSLog(@"New record created: %@", newRecord);
    
    // Adding created object to the storage
    [[SharedData sharedData] addRecord:newRecord];
    
    // Closing the view
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.addressTextField) {
        NSLog(@"Address text field called textFieldShouldReturn");
        [self getLocationFromAddress];
    }
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

- (void)getLocationFromAddress {
    // Initialize Geocoder object to get coordinates from location address (forward geocoding)
    if (!self.geocoder) {
        self.geocoder = [[CLGeocoder alloc] init];
    }
    [self.geocoder geocodeAddressString:self.address
                      completionHandler:^(NSArray<CLPlacemark *> *placemarks, NSError *error) {
                          if ([placemarks count] > 0) {
                              CLPlacemark *currentPlacemark = [placemarks objectAtIndex:0];
                              self.location = currentPlacemark.location;
                              NSLog(@"New Record Location: %@", self.location);
                          }
                      }];
}

- (IBAction)useCurrentLocationSwitchTriggered:(id)sender {
    //NSLog(@"Current Location Switch Triggered");
    UISwitch *switcher = (UISwitch *) sender;
    if (switcher.isOn) {
        //NSLog(@"Switch is ON");
        [self feedAddress];
    } else {
        //NSLog(@"Switch is OFF");
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
             
             // Placemarks array contains addressDictionary dictionary with the following array as one of the values
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
             // Initialize record's location property
             self.location = currentLocation;
         }
     }];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell.reuseIdentifier isEqual:@"Rating"]) {
        //NSLog(@"Rating cell found");
        [self createStarRatingViewForCell:cell
                      withEmptyImageNamed:@"emptyStar"
                     withFilledImageNamed:@"filledStar"
                                   action:@selector(didChangeRating:)];
    }
    if ([cell.reuseIdentifier isEqual:@"Price"]) {
        //NSLog(@"Price cell found");
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
    /*
    [[NSLayoutConstraint constraintWithItem:starRatingView
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:1
                                   constant:28] setActive:YES];
     */
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
    self.rating = sender.value;
}

- (IBAction)didChangePrice:(HCSStarRatingView *)sender {
    NSLog(@"Changed price to %.1f", sender.value);
    self.price = sender.value;
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

    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = self.addPhotoButton.frame;
        frame.origin.x = self.addPhotoButton.frame.origin.x + imageWidth + gap;
        pos += imageWidth + gap;
        self.addPhotoButton.translatesAutoresizingMaskIntoConstraints = YES;
        self.addPhotoButton.frame = frame;
    }];
    [self.photos addObject:image];
}

// Called in view controller setup code.
- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    //NSLog(@"Keybord observer has been set");
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification {
    
    //NSLog(@"Keybord was shown");
    
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    // Initialize currentInsets varyable by current table view's insets
    currentInsets = self.createRecordTableView.contentInset;
    
    // Construct visible rectangle
    CGRect aRect = self.createRecordTableView.frame;
    aRect.size.height -= kbSize.height;
    
    // Get upper left corner (origin) of the current view
    CGPoint point = activeField.superview.superview.frame.origin; // All of the three text fields do have the same level
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    if (!CGRectContainsPoint(aRect, point) ) {
        // Construct new insets
        UIEdgeInsets newInsets = UIEdgeInsetsMake(currentInsets.top + 0.0,
                                                  currentInsets.left + 0.0,
                                                  currentInsets.bottom + kbSize.height,
                                                  currentInsets.right + 0.0);
        
        self.createRecordTableView.contentInset = newInsets;
        self.createRecordTableView.scrollIndicatorInsets = newInsets;
        
        [self.createRecordTableView scrollRectToVisible:activeField.superview.superview.frame animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    //NSLog(@"Keybord will be hidden");
    self.createRecordTableView.contentInset = currentInsets;
    self.createRecordTableView.scrollIndicatorInsets = currentInsets;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    //NSLog(@"TextFieldDidBeginEditing");
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    //NSLog(@"TextFieldDidEndEditing");
    activeField = nil;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    //NSLog(@"TextViewDidBeginEditing");
    activeField = textView;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    //NSLog(@"TextViewDidEndEditing");
    activeField = nil;
}

@end
