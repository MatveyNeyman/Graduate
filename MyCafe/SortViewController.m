//
//  SortViewController.m
//  MyCafe
//
//  Created by User on 1/12/16.
//  Copyright © 2016 Harman. All rights reserved.
//

#import "SortViewController.h"

@interface SortViewController () //<UIPickerViewDelegate, UIPickerViewDataSource> // Realized in IB

@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) NSMutableArray<NSString *> *sortOptions;

@end

@implementation SortViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.pickerView.delegate = self; // Realized in IB
    self.sortOptions = [[NSMutableArray alloc] initWithObjects:@"Default", @"Distance", @"Rating", @"Price", @"Name", @"Type", nil];
    [self.pickerView selectRow:0 inComponent:0 animated:YES];
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)applyButtonClicked:(id)sender {
    NSInteger selectedRow = [self.pickerView selectedRowInComponent:0];
    NSString *stringDescriptor = [self.sortOptions objectAtIndex:selectedRow];
    
    NSSortDescriptor *descriptor;
    
    if ([stringDescriptor isEqualToString:@"Name"]) {
        descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    }
    if ([stringDescriptor isEqualToString:@"Rating"]) {
        descriptor = [[NSSortDescriptor alloc] initWithKey:@"rating" ascending:YES];
    }
    if ([stringDescriptor isEqualToString:@"Price"]) {
        descriptor = [[NSSortDescriptor alloc] initWithKey:@"price" ascending:YES];
    }
    if ([stringDescriptor isEqualToString:@"Type"]) {
        descriptor = [[NSSortDescriptor alloc] initWithKey:@"type" ascending:YES];
    }
    if ([stringDescriptor isEqualToString:@"Distance"]) {
        descriptor = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];
    }
    
    if([self.sortDelegate respondsToSelector:@selector(sortViewControllerDismissed:)]) {
        [self.sortDelegate sortViewControllerDismissed:descriptor];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma  mark - UIPickerViewDataSource
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.sortOptions.count;
}


#pragma  mark - UIPickerViewDelegate

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *rowString = self.sortOptions[row];
    return rowString;
}

@end
