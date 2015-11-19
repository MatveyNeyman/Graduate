//
//  ContainerViewController.m
//  MyCafe
//
//  Created by User on 11/19/15.
//  Copyright © 2015 Harman. All rights reserved.
//

#import "ContainerViewController.h"

#define SegueIdentifierList @"List"
#define SegueIdentifierMap @"Map"

static BOOL _isListView = YES;

@interface ContainerViewController ()

@property (nonatomic) NSString * currentSegueIdentifier;
@property (nonatomic) IBOutlet UIView *mapView;
@property (nonatomic) IBOutlet UITableView *listView;
@property (nonatomic) IBOutlet UIView *parentView;    //may be do not need

@end

@implementation ContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)swapView {
    if (_isListView) {
        [self.listView setHidden:YES];
        [self.mapView setHidden:NO];
        _isListView = NO;
    } else {
        [self.mapView setHidden:YES];
        [self.listView setHidden:NO];
        _isListView = YES;
    }
}

@end
