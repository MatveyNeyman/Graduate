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
#import <AddressBookUI/AddressBookUI.h>


@interface CreateRecordViewController () <CLLocationManagerDelegate>

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
    switch (switcher.isOn) {
        case YES:
            NSLog(@"Switch is ON");
            [self feedAddress];
            break;
        case NO:
            NSLog(@"Switch is OFF");
            self.addressTextField.text = nil;
            break;
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

@end
