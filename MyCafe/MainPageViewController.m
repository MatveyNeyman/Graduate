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

@interface MainPageViewController () <FilterDelegate>
{
    NSString *zeroSegmentName; //initial zero segment's name in UISegmentedControl
    BOOL isMapTitle;           //initial flag
}

// Outlets for containers which contain Map or List scenes
@property (nonatomic) IBOutlet UIView *mapView;
@property (nonatomic) IBOutlet UIView *listView;

@property (nonatomic) FilterViewController *filterViewController;
//@property (nonatomic) NSArray<Record *> *filteredRecords;

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
    }
}


#pragma mark - FilterDelegate

- (void)filterViewControllerDismissed:(NSArray<Record *> *)filteredRecords {
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
                //sort list method
            } else {
                NSLog(@"filter pressed");
                //filter map method
                [self performSegueWithIdentifier:@"Filter" sender:nil];
            }
            break;
        case 2:
            NSLog(@"filter pressed");
            //filter list method
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
