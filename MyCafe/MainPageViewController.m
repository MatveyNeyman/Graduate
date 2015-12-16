//
//  MainPageViewController.m
//  MyCafe
//
//  Created by User on 11/19/15.
//  Copyright © 2015 Harman. All rights reserved.
//

#import "MainPageViewController.h"

@interface MainPageViewController ()

{
    NSString *_zeroSegmentName; //initial zero segment's name in UISegmentedControl
    BOOL _isMapTitle;           //initial flag
}

// Outlets for containers which contain Map or List scenes
@property (nonatomic) IBOutlet UIView *mapView;
@property (nonatomic) IBOutlet UIView *listView;

@end

@implementation MainPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"ListView loaded");
    [self.mapView setHidden:YES];
    _zeroSegmentName = @"Map";
    _isMapTitle = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (IBAction)segmentTriggered:(id)sender {
    UISegmentedControl *mapSortFilter = (UISegmentedControl *) sender;
    switch (mapSortFilter.selectedSegmentIndex) {
        case 0:
            NSLog(@"%@ pressed", _zeroSegmentName);
            [self swapView];
            [mapSortFilter setTitle:_zeroSegmentName forSegmentAtIndex:0];
            if ([_zeroSegmentName  isEqual: @"List"]) {
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
            }
            break;
        case 2:
            NSLog(@"filter pressed");
            //filter list method
            break;
    }
}

- (void)swapView {
    if (_isMapTitle) {
        _zeroSegmentName = @"List";
        [self.listView setHidden:YES];
        [self.mapView setHidden:NO];
        _isMapTitle = NO;
    } else {
        _zeroSegmentName = @"Map";
        [self.mapView setHidden:YES];
        [self.listView setHidden:NO];
        _isMapTitle = YES;
    }
}

@end
