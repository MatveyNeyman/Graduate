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
#import "SharedData.h"
#import "PhotosStore.h"
#import "ImageViewController.h"

@interface CreateRecordViewController () <CLLocationManagerDelegate,
                                        UINavigationControllerDelegate, UIImagePickerControllerDelegate, // Both are needed for image picker
                                        UIPopoverControllerDelegate>
{
    CGFloat pos; // Start position for the first photo
    CGFloat gap; // Gap between photos and leading margin for the first photo
    UIView *activeField;
    UIEdgeInsets currentInsets;
    BOOL doneButtonClicked;
    BOOL isViewExpired;
    CGFloat aPos; // Initial constant value vor addPhotoLeadingConstraint
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
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *addPhotoLeadingConstraint;

@property (nonatomic) TypeSelectorViewController *typeSelectorViewController;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLGeocoder *geocoder;
@property (nonatomic) ImageViewController *ivc;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *address;
@property (nonatomic) CLLocation *location;
@property (nonatomic) NSInteger rating;
@property (nonatomic) NSInteger price;
@property (nonatomic) NSMutableArray<NSString *> *photosKeys;
@property (nonatomic) NSMutableDictionary<NSNumber *, NSString *> *tagPhotoKey;
@property (strong, nonatomic) UIViewController *imagePresenter;

//@property (nonatomic) NSMutableArray<UIImage *> *photos;
@property (nonatomic, copy) NSString *notes;



@end


@implementation CreateRecordViewController

- (void)awakeFromNib {
    self.isEditingMode = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //NSLog(@"New Record loaded");
    self.selectedType = @"Restaurant";
    pos = 0;
    gap = 10;
    aPos = 10;
    doneButtonClicked = NO;
    //isViewExpired = NO;
    [self registerForKeyboardNotifications];
    //self.photos = [[NSMutableArray alloc] init];
    
    if (self.isEditingMode && self.record) {
        self.nameTextField.text = self.record.name;
        self.selectedType = self.record.type;
        self.addressTextField.text = self.record.address;
        self.location = self.record.location;
        self.rating = self.record.rating;
        self.price = self.record.price;
        self.photosKeys = self.record.photosKeys;
        for (NSString *key in self.photosKeys) {
            UIImage *image = [[PhotosStore photosStore] imageForKey:key];
            [self addImage:image withKey:key];
        }
        self.notesTextView.text = self.record.notes;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.typeSelectorViewController.currentType) {
        self.selectedType = self.typeSelectorViewController.currentType;
    }
    self.typeLabel.text = self.selectedType;
    
    if (self.ivc.photosKeys /*|| isViewExpired == YES*/) {
        self.addPhotoLeadingConstraint.constant = aPos;
        pos = 0;
        gap = 10;
        [self reloadPhotoView];
        //isViewExpired = YES;
    }
}

- (void)reloadPhotoView {
    
    // Clear scroll view
    for (NSNumber *tag in self.tagPhotoKey) {
        [[self.scrollPhotosView viewWithTag:[tag integerValue]] removeFromSuperview];
    }
    self.photosKeys = self.ivc.photosKeys;
    self.tagPhotoKey = nil;
    
    /*
     // Find deleted tags
     for (NSNumber *tag in self.tagPhotoKey) {
     NSString *key = self.tagPhotoKey[tag];
     if (![self.photosKeys containsObject:key]) {
     // Delete view with this tag
     [[self.scrollPhotosView viewWithTag:[tag integerValue]] removeFromSuperview];
     }
     }
     */
    /*
     for (UIView *view in self.scrollPhotosView.subviews) {
     NSLog(@"self.scrollPhotosView.subviews contains view with tag %d and with origin x=%f, y=%f", view.tag, view.frame.origin.x, view.frame.origin.y);
     }
     */
    
    // Rearrange photos in the scroll view
    
    for (NSString *key in self.photosKeys) {
        UIImage *image = [[PhotosStore photosStore] imageForKey:key];
        [self addImage:image withKey:key];
    }
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
    doneButtonClicked = YES;
    self.name = self.nameTextField.text;
    self.type = self.selectedType;
    self.address = self.addressTextField.text;
    self.notes = self.notesTextView.text;

    // Check for empty name and show an alert message
    if ([[self.name stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Please input name of the place"
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    // This statement helpful in case of user pressed Done button just after entered address
    if (!self.location || self.address != self.record.address) {
        [self getLocationFromAddress:self.addressTextField.text];
    } else {
        if (self.isEditingMode && self.record) {
            [self saveChanges];
        }
        [self createAndDismiss];
    }
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete Record"
                                                                style:UIAlertActionStyleDestructive
                                                              handler:^(UIAlertAction *action) {
                                                                  // Delete object
                                                                  [[SharedData sharedData] removeRecord:self.record];
                                                                  // Close the view
                                                                  [self.navigationController popToRootViewControllerAnimated:YES];
                                                              }];
        [alert addAction:deleteAction];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction *action) {}];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    //tableView.nu
    return 0.001;
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.isEditingMode) {
        return 2;
    } else {
        return 1;
    }
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
    if (self.isEditingMode && self.record) {
        if ([cell.reuseIdentifier isEqual:@"Rating"]) {
            starRatingView.value = self.record.rating;
        }
        if ([cell.reuseIdentifier isEqual:@"Price"]) {
            starRatingView.value = self.record.price;
        }
    } else {
        starRatingView.value = 0;
    }
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


#pragma mark - UIImagePickerControllerDelegate
// Dealing with taken picture
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    //if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    //    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        //UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    //}
    
    // Create NSUUID object and get its string representation
    NSUUID *uuid = [[NSUUID alloc] init];
    NSString *key = [uuid UUIDString];
    
    if (!self.photosKeys) {
        self.photosKeys = [[NSMutableArray alloc] init];
    }
    [self.photosKeys addObject:key];
    [[PhotosStore photosStore] setImage:image forKey:key];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    //[picker dismissViewControllerAnimated:YES completion:nil];
    
    [self addImage:image withKey:key];
    
    //[self.photos addObject:image];
}

- (void)addImage:(UIImage *)image withKey:(NSString *)key {
    CGFloat aspectRatio = image.size.height / image.size.width; // Aspect ratio for taken/choosen image
    CGFloat thumbnailWidth;     // Placeholder's width
    CGFloat thumbnailHeight;    // Placeholder's height
    CGFloat originY;            // Placeholder's center point
    
    // Check portrait or landscape view
    if (aspectRatio >= 1) {
        thumbnailWidth = 70 / aspectRatio;
        thumbnailHeight = 70;
    } else {
        thumbnailWidth = 70;
        thumbnailHeight = 70 * aspectRatio;
    }
    // Create the ImageView for thumbnails
    originY = (self.scrollPhotosView.frame.size.height - thumbnailHeight) / 2;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(pos + gap, originY, thumbnailWidth, thumbnailHeight)];
    
    imageView.userInteractionEnabled = YES;
    
    // We make +1 in order to distinct this tag from 0 tag which all other views have
    imageView.tag = pos + 1;
    NSNumber *tag = @(imageView.tag);
    
    if (!self.tagPhotoKey) {
        self.tagPhotoKey = [[NSMutableDictionary alloc] init];
    }
    self.tagPhotoKey[tag] = key;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)];
    tap.numberOfTapsRequired = 1;
    
    [imageView addGestureRecognizer:tap];
    
    //CGFloat scale = image.scale;
    //CGSize size = image.size;
    
    // Resize the image
    CGSize thumbnailSize;
    thumbnailSize.width = thumbnailWidth;
    thumbnailSize.height = thumbnailHeight;
    UIGraphicsBeginImageContextWithOptions(thumbnailSize, NO, 0);
    [image drawInRect:CGRectMake(0, 0, thumbnailWidth, thumbnailHeight)];
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //CGFloat newScale = thumbnail.scale;
    //CGSize newSize = thumbnail.size;
    
    // Set resized image for the view
    imageView.image = thumbnail;
    //imageView.image = image;
    
    [self.scrollPhotosView addSubview:imageView];
    
    pos += thumbnailWidth + gap;
    self.addPhotoLeadingConstraint.constant = pos + aPos;
    
    /*
    [UIView animateWithDuration:0.5 animations:^ {
        CGRect frame = self.addPhotoButton.frame;
        frame.origin.x = self.addPhotoButton.frame.origin.x + thumbnailWidth + gap;
        pos += thumbnailWidth + gap;
        self.addPhotoButton.translatesAutoresizingMaskIntoConstraints = YES;
        self.addPhotoButton.frame = frame;
    }];
    */
}

- (void)tapImage:(UIGestureRecognizer *)gestureRecognizer {
    UIImageView *imageView = (UIImageView *)gestureRecognizer.view;
    NSInteger intTag = imageView.tag;
    NSNumber *tag = @(intTag);
    NSString *key = self.tagPhotoKey[tag];
    
    self.ivc = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageViewController"];
    self.ivc.photosKeys = self.photosKeys;
    self.ivc.startKey = key;
    self.ivc.isEditingMode = YES;
    [self.navigationController pushViewController:self.ivc animated:YES];
}


#pragma mark - Move view above keyboard
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


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.addressTextField) {
        NSLog(@"Address text field called textFieldShouldReturn");
        [self getLocationFromAddress:self.addressTextField.text];
    }
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    //NSLog(@"TextFieldDidBeginEditing");
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"TextFieldDidEndEditing");
    activeField = nil;
    if (textField == self.addressTextField) {
        [self getLocationFromAddress:self.addressTextField.text];
    }
}


#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    //NSLog(@"TextViewDidBeginEditing");
    activeField = textView;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    //NSLog(@"TextViewDidEndEditing");
    activeField = nil;
}


- (void)getLocationFromAddress:(NSString *)address {
    // Initialize Geocoder object to get coordinates from location address (forward geocoding)
    if (!self.geocoder) {
        self.geocoder = [[CLGeocoder alloc] init];
    }
    [self.geocoder geocodeAddressString:address
                      completionHandler:^(NSArray<CLPlacemark *> *placemarks, NSError *error) {
                          if ([placemarks count] > 0) {
                              CLPlacemark *currentPlacemark = [placemarks objectAtIndex:0];
                              self.location = currentPlacemark.location;
                              NSLog(@"New Record Location: %@", self.location);
                          }
                          if (doneButtonClicked && !self.isEditingMode) {
                              [self createAndDismiss];
                          }
                          if (doneButtonClicked && self.isEditingMode) {
                              [self saveChanges];
                          }
                      }];
}

- (void)createAndDismiss {
    // Creating new Record object initialized by the corresponding properties and adding it to the array
    Record *newRecord = [[Record alloc] initWithName:self.name
                                                type:self.type
                                             address:self.address
                                            location:self.location
                                              rating:self.rating
                                               price:self.price
                                          photosKeys:self.photosKeys
                                               notes:self.notes];
    NSLog(@"New record created: %@", newRecord);
    
    // Adding created object to the storage
    [[SharedData sharedData] addRecord:newRecord];
    
    // Close the view
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveChanges {
    Record *modifiedRecord = [[Record alloc] initWithName:self.name
                                                     type:self.type
                                                  address:self.address
                                                 location:self.location
                                                   rating:self.rating
                                                    price:self.price
                                               photosKeys:self.photosKeys
                                                    notes:self.notes];
    [[SharedData sharedData] replaceRecord:self.record withRecord:modifiedRecord];
    //[self.navigationController popViewControllerAnimated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
