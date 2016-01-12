//
//  MainPageViewController.h
//  MyCafe
//
//  Created by User on 11/19/15.
//  Copyright © 2015 Harman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Record.h"
#import "FilterViewController.h"

@interface MainPageViewController : UIViewController

@property (nonatomic) NSArray<Record *> *filteredRecords;

@end
