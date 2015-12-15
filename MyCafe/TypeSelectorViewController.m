//
//  TypeSelectorViewController.m
//  MyCafe
//
//  Created by User on 12/11/15.
//  Copyright © 2015 Harman. All rights reserved.
//

#import "TypeSelectorViewController.h"

@interface TypeSelectorViewController ()

@property(strong, nonatomic) NSMutableArray<NSString *> *types;
@property (strong, nonatomic) IBOutlet UITableView *typesTableView;

@end

@implementation TypeSelectorViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"Type selector loaded");
    
    self.types = [[NSMutableArray alloc] initWithObjects:@"Restaurant", @"Cafe", @"Bar", @"Fast Food", nil];

    NSLog(@"Current Type: %@", self.currentType);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.types count];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == [self.types indexOfObject:self.currentType]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSInteger typeIndex = [self.types indexOfObject:self.currentType];
    
    if (typeIndex == indexPath.row) {
        return;
    }
    
    NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:typeIndex inSection:0];
    
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    if (newCell.accessoryType == UITableViewCellAccessoryNone) {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.currentType = [self.types objectAtIndex:indexPath.row];
    }
    
    UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
    if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark) {
        oldCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    NSLog(@"Type selected: %@", self.currentType);
}

@end

//Construct cell programmatically
/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
 UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
 NSLog(@"Cell Index: %d", indexPath.row);
 
 if (cell == nil) {
 cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NULL];
 if (indexPath.row == [self.types indexOfObject:self.currentType]) {
 cell.accessoryType = UITableViewCellAccessoryCheckmark;
 }
 }
 
 return cell;
 }
 */

/*
 typedef NS_ENUM(NSInteger, Type) {
 Restaurant,
 Cafe,
 Bar,
 Fast_Food
 };
 */

