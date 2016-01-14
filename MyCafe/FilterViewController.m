//
//  FilterViewController.m
//  MyCafe
//
//  Created by User on 1/12/16.
//  Copyright © 2016 Harman. All rights reserved.
//

#import "FilterViewController.h"
#import "MultiSelectSegmentedControl.h"
#import "SharedData.h"

@interface FilterViewController ()

@property (strong, nonatomic) IBOutlet UISwitch *restaurantSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *cafeSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *barSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *fastFoodSwitch;

@property (strong, nonatomic) IBOutlet MultiSelectSegmentedControl *starsSegmentedControl;
@property (strong, nonatomic) IBOutlet MultiSelectSegmentedControl *coinsSegmentedControl;

@property (nonatomic) NSMutableArray<Record *> *filteredRecords;

@end


@implementation FilterViewController

//@synthesize filterDelegate;

/*
// Overriding getter method for public list
- (NSArray<Record *> *)pFilteredRecords {
    return self.filteredRecords;
}
*/
 
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    self.filteredRecords = [NSMutableArray arrayWithArray:[SharedData sharedData].listOfRecords];
    
    if (!self.showRestaurant) {
        self.restaurantSwitch.on = NO;
    }
    if (!self.showCafe) {
        self.cafeSwitch.on = NO;
    }
    if (!self.showBar) {
        self.barSwitch.on = NO;
    }
    if (!self.showFastFood) {
        self.fastFoodSwitch.on = NO;
    }
    if (self.selectedStars) {
        self.starsSegmentedControl.selectedSegmentIndexes = self.selectedStars;
    }
    if (self.selectedCoins) {
        NSLog(@"self.selectedCoins %@", self.selectedCoins);
        self.coinsSegmentedControl.selectedSegmentIndexes = self.selectedCoins;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 0;
}
*/
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        NSLog(@"Reset filter settings");
        [self.restaurantSwitch setOn:YES animated:YES];
        [self.cafeSwitch setOn:YES animated:YES];
        [self.barSwitch setOn:YES animated:YES];
        [self.fastFoodSwitch setOn:YES animated:YES];
        self.starsSegmentedControl.selectedSegmentIndexes = nil;
        self.coinsSegmentedControl.selectedSegmentIndexes = nil;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (IBAction)cancelButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)applyButtonClicked:(id)sender {
    
    // Initialize stars and coins selections
    self.selectedStars = self.starsSegmentedControl.selectedSegmentIndexes;
    self.selectedCoins = self.coinsSegmentedControl.selectedSegmentIndexes;
    
    //NSLog(@"Selected Stars %@", self.selectedStars);
    //NSLog(@"Selected Coins %@", self.selectedCoins);
    
    // Check type switches
    if (self.restaurantSwitch.on) {
        self.showRestaurant = YES;
    } else {
        self.showRestaurant = NO;
    }
    if (self.cafeSwitch.on) {
        self.showCafe = YES;
    } else {
        self.showCafe = NO;
    }
    if (self.barSwitch.on) {
        self.showBar = YES;
    } else {
        self.showBar = NO;
    }
    if (self.fastFoodSwitch.on) {
        self.showFastFood = YES;
    } else {
        self.showFastFood = NO;
    }
    
    // Create a copy of array for enumeration
    NSMutableArray *records = [[NSMutableArray alloc ] initWithArray:self.filteredRecords];
    
    for (Record *record in records) {
        // Check type
        if ([record.type isEqualToString:@"Restaurant"] && self.showRestaurant == NO) {
            [self.filteredRecords removeObject:record];
            continue;
        }
        if ([record.type isEqualToString:@"Cafe"] && self.showCafe == NO) {
            [self.filteredRecords removeObject:record];
            continue;
        }
        if ([record.type isEqualToString:@"Bar"] && self.showBar == NO) {
            [self.filteredRecords removeObject:record];
            continue;
        }
        if ([record.type isEqualToString:@"Fast Food"] && self.showFastFood == NO) {
            [self.filteredRecords removeObject:record];
            continue;
        }
        // Check rating
        if (record.rating == 0 && self.selectedStars.count > 0) {
            [self.filteredRecords removeObject:record];
            continue;
        }
        if (record.rating == 1 && self.selectedStars.count > 0 && ![self.selectedStars containsIndex:0]) {
            [self.filteredRecords removeObject:record];
            continue;
        }
        if (record.rating == 2 && self.selectedStars.count > 0 && ![self.selectedStars containsIndex:1]) {
            [self.filteredRecords removeObject:record];
            continue;
        }
        if (record.rating == 3 && self.selectedStars.count > 0 && ![self.selectedStars containsIndex:2]) {
            [self.filteredRecords removeObject:record];
            continue;
        }
        if (record.rating == 4 && self.selectedStars.count > 0 && ![self.selectedStars containsIndex:3]) {
            [self.filteredRecords removeObject:record];
        }
        if (record.rating == 5 && self.selectedStars.count > 0 && ![self.selectedStars containsIndex:4]) {
            [self.filteredRecords removeObject:record];
            continue;
        }
        // Check price
        if (record.price == 0 && self.selectedCoins.count > 0) {
            [self.filteredRecords removeObject:record];
            continue;
        }
        if (record.price == 1 && self.selectedCoins.count > 0 && ![self.selectedCoins containsIndex:0]) {
            [self.filteredRecords removeObject:record];
            continue;
        }
        if (record.price == 2 && self.selectedCoins.count > 0 && ![self.selectedCoins containsIndex:1]) {
            [self.filteredRecords removeObject:record];
            continue;
        }
        if (record.price == 3 && self.selectedCoins.count > 0 && ![self.selectedCoins containsIndex:2]) {
            [self.filteredRecords removeObject:record];
            continue;
        }
        if (record.price == 4 && self.selectedCoins.count > 0 && ![self.selectedCoins containsIndex:3]) {
            [self.filteredRecords removeObject:record];
            continue;
        }
        if (record.price == 5 && self.selectedCoins.count > 0 && ![self.selectedCoins containsIndex:4]) {
            [self.filteredRecords removeObject:record];
            continue;
        }
    }
    
    if([self.filterDelegate respondsToSelector:@selector(filterViewControllerDismissed:selectedStars:selectedCoins:showRestaurant:showCafe:showBar:showFastFood:)]) {
        [self.filterDelegate filterViewControllerDismissed:self.filteredRecords
                                             selectedStars:self.selectedStars
                                             selectedCoins:self.selectedCoins
                                            showRestaurant:self.showRestaurant
                                                  showCafe:self.showCafe
                                                   showBar:self.showBar
                                              showFastFood:self.showFastFood];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
