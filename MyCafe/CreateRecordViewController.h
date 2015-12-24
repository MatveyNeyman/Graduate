//
//  NewRecordViewController.h
//  MyCafe
//
//  Created by User on 12/10/15.
//  Copyright © 2015 Harman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Record.h"

@interface CreateRecordViewController : UITableViewController

@property (nonatomic, copy) NSString *selectedType;
@property (nonatomic) BOOL isEditingMode;
@property (nonatomic) Record *record;

@end
