//
//  NewRecordViewController.m
//  MyCafe
//
//  Created by User on 12/10/15.
//  Copyright © 2015 Harman. All rights reserved.
//

#import "NewRecordViewController.h"

@interface NewRecordViewController ()
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@end

@implementation NewRecordViewController

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
- (IBAction)cancelButtonClicked:(id)sender {
    NSLog(@"New Record appeared");
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)doneButtonClicked:(id)sender {
    
}

@end
