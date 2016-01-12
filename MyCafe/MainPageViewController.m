//
//  MainPageViewController.m
//  MyCafe
//
//  Created by User on 11/19/15.
//  Copyright © 2015 Harman. All rights reserved.
//

#import "MainPageViewController.h"
#import "SharedData.h"
#import "ListViewController.h"
#import "MapViewController.h"
#import "FilterViewController.h"
#import "SortViewController.h"

@interface MainPageViewController () <FilterDelegate, SortDelegate>
{
    NSString *zeroSegmentName; //initial zero segment's name in UISegmentedControl
    BOOL isMapTitle;           //initial flag
}

// Outlets for containers which contain Map or List scenes
@property (nonatomic) IBOutlet UIView *mapView;
@property (nonatomic) IBOutlet UIView *listView;

@property (nonatomic) FilterViewController *filterViewController;
@property (nonatomic) SortViewController *sortViewController;
//@property (nonatomic) NSArray<Record *> *filteredRecords;

@property (nonatomic) NSIndexSet *selectedStars;
@property (nonatomic) NSIndexSet *selectedCoins;
@property (nonatomic) BOOL showRestaurant;
@property (nonatomic) BOOL showCafe;
@property (nonatomic) BOOL showBar;
@property (nonatomic) BOOL showFastFood;

//@property (nonatomic) NSString *sortDescriptor;
@property (nonatomic) NSSortDescriptor *descriptor;

@end

@implementation MainPageViewController

- (void)awakeFromNib {
    NSLog(@"MainPage awaked from nib");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"MainPage loaded");
    // Do any additional setup after loading the view.
    [self.mapView setHidden:YES];
    zeroSegmentName = @"Map";
    isMapTitle = YES;
    self.showRestaurant = YES;
    self.showCafe = YES;
    self.showBar = YES;
    self.showFastFood = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"Filtered records: %@", self.filteredRecords);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Filter"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        self.filterViewController = (FilterViewController *) [navigationController topViewController];
        self.filterViewController.filterDelegate = self;
        self.filterViewController.selectedStars = self.selectedStars;
        self.filterViewController.selectedCoins = self.selectedCoins;
        self.filterViewController.showRestaurant = self.showRestaurant;
        self.filterViewController.showCafe = self.showCafe;
        self.filterViewController.showBar = self.showBar;
        self.filterViewController.showFastFood = self.showFastFood;
        //NSLog(@"self.selectedCoins %@", self.selectedCoins);
    }
    if ([segue.identifier isEqualToString:@"Sort"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        self.sortViewController = (SortViewController *) [navigationController topViewController];
        self.sortViewController.sortDelegate = self;
    }
}


#pragma mark - FilterDelegate

- (void)filterViewControllerDismissed:(NSArray<Record *> *)filteredRecords
                        selectedStars:(NSIndexSet *)selectedStars
                        selectedCoins:(NSIndexSet *)selectedCoins
                       showRestaurant:(BOOL)showRestaurant
                             showCafe:(BOOL)showCafe
                              showBar:(BOOL)showBar
                         showFastFood:(BOOL)showFastFood {
    
    self.selectedStars = selectedStars;
    self.selectedCoins = selectedCoins;
    self.showRestaurant = showRestaurant;
    self.showCafe = showCafe;
    self.showBar = showBar;
    self.showFastFood = showFastFood;
    
    ListViewController *lvc;
    MapViewController *mvc;
    
    for (UIViewController *vc in self.childViewControllers) {
        if ([vc isKindOfClass:[ListViewController class]]) {
            lvc = (ListViewController *) vc;
        }
        if ([vc isKindOfClass:[MapViewController class]]) {
            mvc = (MapViewController *) vc;
        }
    }
    
    if (filteredRecords.count != [SharedData sharedData].listOfRecords.count) {
        self.filteredRecords = filteredRecords;
        lvc.isFilterEnabled = YES;
        mvc.isFilterEnabled = YES;
    } else {
        lvc.isFilterEnabled = NO;
        mvc.isFilterEnabled = NO;
    }
}


#pragma mark - SortDelegate

- (void)sortViewControllerDismissed:(NSSortDescriptor *)descriptor {
    self.descriptor = descriptor;
    NSLog(@"Sort descriptor: %@", self.descriptor);
    
    for (UIViewController *vc in self.childViewControllers) {
        if ([vc isKindOfClass:[ListViewController class]]) {
            ListViewController *lvc = (ListViewController *) vc;
            lvc.descriptor = self.descriptor;
        }
    }
}


- (IBAction)segmentTriggered:(id)sender {
    UISegmentedControl *mapSortFilter = (UISegmentedControl *) sender;
    switch (mapSortFilter.selectedSegmentIndex) {
        case 0:
            NSLog(@"%@ pressed", zeroSegmentName);
            [self swapView];
            [mapSortFilter setTitle:zeroSegmentName forSegmentAtIndex:0];
            if ([zeroSegmentName  isEqual: @"List"]) {
                [mapSortFilter removeSegmentAtIndex:1 animated:YES];
            } else {
                [mapSortFilter insertSegmentWithTitle:@"Sort" atIndex:1 animated:YES];
            }
            break;
        case 1:
            if ([mapSortFilter numberOfSegments] == 3) {
                NSLog(@"sort pressed");
                [self performSegueWithIdentifier:@"Sort" sender:nil];
            } else {
                NSLog(@"filter pressed");
                [self performSegueWithIdentifier:@"Filter" sender:nil];
            }
            break;
        case 2:
            NSLog(@"filter pressed");
            [self performSegueWithIdentifier:@"Filter" sender:nil];
            break;
    }
}

- (void)swapView {
    if (isMapTitle) {
        zeroSegmentName = @"List";
        [self.listView setHidden:YES];
        [self.mapView setHidden:NO];
        isMapTitle = NO;
    } else {
        zeroSegmentName = @"Map";
        [self.mapView setHidden:YES];
        [self.listView setHidden:NO];
        isMapTitle = YES;
    }
}

@end
