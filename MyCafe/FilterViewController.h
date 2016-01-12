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
- (void)filterViewControllerDismissed:(NSArray<Record *> *)filteredRecords
                        selectedStars:(NSIndexSet *)selectedStars
                        selectedCoins:(NSIndexSet *)selectedCoins
                       showRestaurant:(BOOL)showRestaurant
                             showCafe:(BOOL)showCafe
                              showBar:(BOOL)showBar
                         showFastFood:(BOOL)showFastFood;
@end


@interface FilterViewController : UITableViewController
// Delegate property
@property (nonatomic, weak) id<FilterDelegate> filterDelegate;

@property (nonatomic, copy) NSIndexSet *selectedStars;
@property (nonatomic, copy) NSIndexSet *selectedCoins;
@property (nonatomic) BOOL showRestaurant;
@property (nonatomic) BOOL showCafe;
@property (nonatomic) BOOL showBar;
@property (nonatomic) BOOL showFastFood;

@end


