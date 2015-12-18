//
//  ListViewCell.m
//  MyCafe
//
//  Created by User on 12/17/15.
//  Copyright © 2015 Harman. All rights reserved.
//

#import "ListViewCell.h"
#import <HCSStarRatingView/HCSStarRatingView.h>

@interface ListViewCell ()
{
    CGFloat iconSize;
}

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *typeLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;

@end

@implementation ListViewCell

// To use custom initializer the view controller must call
// [tableView registerClass:[ListViewCell class] forCellReuseIdentifier:@"ListCell"];
/*
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSLog(@"Custom Cell ListViewCell created");
    }
    return self;
}
*/

- (void)awakeFromNib {
    // Initialization code
    NSLog(@"Custom Cell awaked from NIB");
    iconSize = 14;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    NSLog(@"Custom Cell ListViewCell selected");
}

- (void)fillData {
    for (int i = 0; i < self.cellRecord.rating; i++) {
        CGFloat originY = self.contentView.frame.origin.y + 10;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(8 + iconSize * i, originY, iconSize, iconSize)];
        imageView.image = [UIImage imageNamed:@"filledStar"];
        [self.contentView addSubview:imageView];
    }
    for (int i = 0; i < self.cellRecord.price; i++) {
        CGFloat originY = (self.contentView.frame.size.height / 2) - (iconSize / 2);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(8 + iconSize * i, originY, iconSize, iconSize)];
        imageView.image = [UIImage imageNamed:@"filledCoin"];
        [self.contentView addSubview:imageView];
    }
    
    self.nameLabel.text = self.cellRecord.name;
    self.typeLabel.text = self.cellRecord.type;
    self.addressLabel.text = self.cellRecord.address;
}

@end
