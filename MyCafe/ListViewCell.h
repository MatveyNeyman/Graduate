//
//  ListViewCell.h
//  MyCafe
//
//  Created by User on 12/17/15.
//  Copyright © 2015 Harman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Record.h"

@interface ListViewCell : UITableViewCell

@property (nonatomic)  Record *cellRecord;

- (void)fillData;

@end
