//
//  NewRecordViewController.m
//  MyCafe
//
//  Created by User on 12/10/15.
//  Copyright © 2015 Harman. All rights reserved.
//

#import "NewRecordViewController.h"
#import "TypeSelectorViewController.h"

@interface NewRecordViewController ()

@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UILabel *typeLabel;
@property(nonatomic) TypeSelectorViewController *typeSelectorViewController;

@end

@implementation NewRecordViewController

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

@end
