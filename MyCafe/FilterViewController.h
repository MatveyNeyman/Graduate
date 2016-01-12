//
//  FilterViewController.h
//  MyCafe
//
//  Created by User on 1/12/16.
//  Copyright © 2016 Harman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Record.h"

// Declare protocol for passing data back after filter has been set
@protocol FilterDelegate <NSObject>
- (void)filterViewControllerDismissed:(NSArray<Record *> *)filteredRecords;
@end


@interface FilterViewController : UITableViewController

// Delegate property
@property (nonatomic, weak) id<FilterDelegate> filterDelegate;

@end


