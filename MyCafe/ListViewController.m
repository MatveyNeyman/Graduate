//
//  ListViewController.m
//  MyCafe
//
//  Created by User on 12/17/15.
//  Copyright © 2015 Harman. All rights reserved.
//

#import "ListViewController.h"
#import "MainPageViewController.h"
#import "SharedData.h"
#import "ListViewCell.h"
#import "RecordViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "FilterViewController.h"

@interface ListViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *listTableView;

@property (nonatomic, copy) NSArray<Record *> *records;
@property (nonatomic) RecordViewController *recordViewController;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;

@end

@implementation ListViewController

- (void)awakeFromNib {
    NSLog(@"ListView awaked from nib");
    // Initializing SharedData singleton and array with records
    //self.records = [SharedData sharedData].listOfRecords;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    self.currentLocation = self.locationManager.location;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(searchProvide:)
                                                 name:@"searchBegin"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(searchDismiss:)
                                                 name:@"searchCancel"
                                               object:nil];
    
    //NSLog(@"ListView loaded");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //NSLog(@"ListView appeared");

    // Initializing SharedData singleton and array with records
    self.records = [SharedData sharedData].listOfRecords;
    
    //NSLog(@"Records array in ListViewController: %@", self.records);
    
    MainPageViewController *mpvc = (MainPageViewController *) self.parentViewController;
    if (self.isFilterEnabled) {
        if (mpvc.filteredRecords) {
            self.records = mpvc.filteredRecords;
        }
    }

    // Reset filter flag
    //self.isFilterEnabled = NO;
    
    NSLog(@"ListView Sort Descriptor: %@", self.descriptor);
    
    // Sort array using descriptor got from MainPageViewController
    if (self.descriptor && ![self.descriptor.key isEqualToString:@"distance"]) {
        NSArray *sortDescriptors = @[self.descriptor];
        NSArray<Record*> *sortedArray = [self.records sortedArrayUsingDescriptors:sortDescriptors];
        self.records = sortedArray;
        //NSLog(@"ListView Sorted Array: %@", sortedArray);
    }
    
    // Sort array manually by locations
    if ([self.descriptor.key isEqualToString:@"distance"]) {
        NSArray<Record*> *sortedArray = [self.records sortedArrayUsingComparator:^NSComparisonResult(Record *a, Record *b) {
            NSInteger distanceA = [a.location distanceFromLocation:self.currentLocation];
            NSInteger distanceB = [b.location distanceFromLocation:self.currentLocation];
            if (distanceA < distanceB) {
                return NSOrderedAscending;
            }
            if (distanceA > distanceB) {
                return NSOrderedDescending;
            }
            if (distanceA == distanceB) {
                return NSOrderedSame;
            }
            else {
                return NSOrderedSame;
            }
        }];
        
        self.records = sortedArray;
        //NSLog(@"ListView Sorted Array: %@", sortedArray);
    }

    [[SharedData sharedData] updateLocation];
    // Updatind table view sending message to the tableView property of UITableViewController superclass
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.records count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Register custom class in accordance with UITableView class reference (there are some other ways described in apple develop library)
    //[tableView registerClass:[ListViewCell class] forCellReuseIdentifier:@"ListCell"];
    
    ListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListCell" forIndexPath:indexPath];

    cell.star1.image = nil;
    cell.star2.image = nil;
    cell.star3.image = nil;
    cell.star4.image = nil;
    cell.star5.image = nil;
    cell.coin1.image = nil;
    cell.coin2.image = nil;
    cell.coin3.image = nil;
    cell.coin4.image = nil;
    cell.coin5.image = nil;
    
    //cell.cellRecord = self.records[indexPath.row];
    //[cell fillData];
    
    Record *currentRecord = self.records[indexPath.row];
    
    cell.nameLabel.text = currentRecord.name;
    cell.typeLabel.text = currentRecord.type;
    cell.addressLabel.text = currentRecord.address;
    
    switch (currentRecord.rating) {
        case 1:
            cell.star1.image = [UIImage imageNamed:@"filledStar"];
            break;
        case 2:
            cell.star1.image = [UIImage imageNamed:@"filledStar"];
            cell.star2.image = [UIImage imageNamed:@"filledStar"];
            break;
        case 3:
            cell.star1.image = [UIImage imageNamed:@"filledStar"];
            cell.star2.image = [UIImage imageNamed:@"filledStar"];
            cell.star3.image = [UIImage imageNamed:@"filledStar"];
            break;
        case 4:
            cell.star1.image = [UIImage imageNamed:@"filledStar"];
            cell.star2.image = [UIImage imageNamed:@"filledStar"];
            cell.star3.image = [UIImage imageNamed:@"filledStar"];
            cell.star4.image = [UIImage imageNamed:@"filledStar"];
            break;
        case 5:
            cell.star1.image = [UIImage imageNamed:@"filledStar"];
            cell.star2.image = [UIImage imageNamed:@"filledStar"];
            cell.star3.image = [UIImage imageNamed:@"filledStar"];
            cell.star4.image = [UIImage imageNamed:@"filledStar"];
            cell.star5.image = [UIImage imageNamed:@"filledStar"];
            break;
        default:
            cell.star1.image = nil;
            cell.star2.image = nil;
            cell.star3.image = nil;
            cell.star4.image = nil;
            cell.star5.image = nil;
            break;
    }
    
    switch (currentRecord.price) {
        case 1:
            cell.coin1.image = [UIImage imageNamed:@"filledCoin"];
            break;
        case 2:
            cell.coin1.image = [UIImage imageNamed:@"filledCoin"];
            cell.coin2.image = [UIImage imageNamed:@"filledCoin"];
            break;
        case 3:
            cell.coin1.image = [UIImage imageNamed:@"filledCoin"];
            cell.coin2.image = [UIImage imageNamed:@"filledCoin"];
            cell.coin3.image = [UIImage imageNamed:@"filledCoin"];
            break;
        case 4:
            cell.coin1.image = [UIImage imageNamed:@"filledCoin"];
            cell.coin2.image = [UIImage imageNamed:@"filledCoin"];
            cell.coin3.image = [UIImage imageNamed:@"filledCoin"];
            cell.coin4.image = [UIImage imageNamed:@"filledCoin"];
            break;
        case 5:
            cell.coin1.image = [UIImage imageNamed:@"filledCoin"];
            cell.coin2.image = [UIImage imageNamed:@"filledCoin"];
            cell.coin3.image = [UIImage imageNamed:@"filledCoin"];
            cell.coin4.image = [UIImage imageNamed:@"filledCoin"];
            cell.coin5.image = [UIImage imageNamed:@"filledCoin"];
            break;
        default:
            cell.coin1.image = nil;
            cell.coin2.image = nil;
            cell.coin3.image = nil;
            cell.coin4.image = nil;
            cell.coin5.image = nil;
            break;
    }

    
    cell.distanceLabel.text = [[SharedData sharedData] distanceToRecord:currentRecord];
    
    /*
    if (currentRecord.location) {
        CLLocationDistance distance = [currentRecord.location distanceFromLocation:self.currentLocation];
        if (distance > 0 && distance <= 950) {
            NSInteger roundedDistanceTo50 = (NSInteger)ceil(distance / 50) * 50;
            cell.distanceLabel.text = [NSString stringWithFormat:@"%ld m", (long)roundedDistanceTo50];
        }
        if (distance > 950 && distance <= 9900) {
            double roundedDistanceTo100 = (NSInteger)ceil(distance / 100);
            roundedDistanceTo100 = roundedDistanceTo100 * 100 / 1000;
            cell.distanceLabel.text = [NSString stringWithFormat:@"%.1f km", roundedDistanceTo100];
        }
        if (distance > 9900) {
            NSInteger roundedDistanceTo1000 = (NSInteger)ceil(distance / 1000);
            cell.distanceLabel.text = [NSString stringWithFormat:@"%ld km", (long)roundedDistanceTo1000];
        }
    } else {
        cell.distanceLabel.text = @"";
    }
    */
    
    return cell;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"Prepare for segue in ListViewController");
    self.recordViewController = [segue destinationViewController];
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSLog(@"Click!");
    self.recordViewController.record = [self.records objectAtIndex:indexPath.row];
}


- (void)searchProvide:(NSNotification *)notification {
    NSString *searchString = notification.userInfo[@"searchString"];
    NSLog(@"String for search in List: %@", searchString);
    
    NSMutableArray *searchResults = [NSMutableArray array];
    
    for (Record *record in self.records) {
        if ([record.name localizedCaseInsensitiveContainsString:searchString]) {
            [searchResults addObject:record];
            continue;
        }
        if ([record.type localizedCaseInsensitiveContainsString:searchString]) {
            [searchResults addObject:record];
            continue;
        }
        if ([record.address localizedCaseInsensitiveContainsString:searchString]) {
            [searchResults addObject:record];
            continue;
        }
        if ([record.notes localizedCaseInsensitiveContainsString:searchString]) {
            [searchResults addObject:record];
            continue;
        }
    }
    self.records = searchResults;
    [self.tableView reloadData];
}

- (void)searchDismiss:(NSNotification *)notification {
    self.records = [SharedData sharedData].listOfRecords;
    [self.tableView reloadData];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

@end
