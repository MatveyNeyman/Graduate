//
//  MainPageViewController.m
//  MyCafe
//
//  Created by User on 11/19/15.
//  Copyright © 2015 Harman. All rights reserved.
//

#import "MainPageViewController.h"
#import "ContainerViewController.h"

static NSString *_zeroSegmentName = @"Map"; //initial name
static BOOL _isMapTitle = YES;

@interface MainPageViewController ()

@property (nonatomic) ContainerViewController *containerViewController;

@end

@implementation MainPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    self.containerViewController = segue.destinationViewController; //DO NOT DELETE
}

- (IBAction)segmentTriggered:(id)sender {
    UISegmentedControl *mapSortFilter = (UISegmentedControl *) sender;
    switch (mapSortFilter.selectedSegmentIndex) {
        case 0:
            NSLog(@"%@ pressed", _zeroSegmentName);
            [self swapTitle];
            [self.containerViewController swapView];
            [mapSortFilter setTitle:_zeroSegmentName forSegmentAtIndex:0];
            break;
        case 1:
            NSLog(@"sort");
            break;
        case 2:
            NSLog(@"filter");
            break;
    }
}

- (void)swapTitle {
    if (_isMapTitle) {
        _zeroSegmentName = @"List";
        _isMapTitle = NO;
    } else {
        _zeroSegmentName = @"Map";
        _isMapTitle = YES;
    }
    
}

@end
