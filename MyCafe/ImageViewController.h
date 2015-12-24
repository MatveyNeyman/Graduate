//
//  ImageViewController.h
//  MyCafe
//
//  Created by User on 12/24/15.
//  Copyright © 2015 Harman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController

//@property (strong, nonatomic) UIImage *image;
@property (nonatomic) NSMutableArray<NSString *> *photosKeys;
@property (nonatomic, copy) NSString *startKey;

@end
