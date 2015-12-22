//
//  ListViewCell.h
//  MyCafe
//
//  Created by User on 12/17/15.
//  Copyright © 2015 Harman. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "Record.h"
@class Record;

@interface ListViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *typeLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UIImageView *star1;
@property (strong, nonatomic) IBOutlet UIImageView *star2;
@property (strong, nonatomic) IBOutlet UIImageView *star3;
@property (strong, nonatomic) IBOutlet UIImageView *star4;
@property (strong, nonatomic) IBOutlet UIImageView *star5;
@property (strong, nonatomic) IBOutlet UIImageView *coin1;
@property (strong, nonatomic) IBOutlet UIImageView *coin2;
@property (strong, nonatomic) IBOutlet UIImageView *coin3;
@property (strong, nonatomic) IBOutlet UIImageView *coin4;
@property (strong, nonatomic) IBOutlet UIImageView *coin5;

//@property (nonatomic) Record *cellRecord;

//- (void)fillData;

@end
