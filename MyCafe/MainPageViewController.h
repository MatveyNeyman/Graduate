//
//  MainPageViewController.h
//  MyCafe
//
//  Created by User on 11/19/15.
//  Copyright © 2015 Harman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Record.h"

@interface MainPageViewController : UIViewController

@property (nonatomic) NSArray<Record *> *filteredRecords;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@end
