//
//  Record.h
//  MyCafe
//
//  Created by User on 12/17/15.
//  Copyright © 2015 Harman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Record : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *type;
@property (nonatomic) NSString *address;
@property (nonatomic) NSInteger rating;
@property (nonatomic) NSInteger price;
@property (nonatomic) NSMutableArray<UIImage *> *photos;
@property (nonatomic) NSString *notes;

- (instancetype)initWithName:(NSString *)name
                        type:(NSString *)type
                     address:(NSString *)address
                      rating:(NSInteger)rating
                       price:(NSInteger)price
                      photos:(NSMutableArray<UIImage *> *)photos
                       notes:(NSString *)notes;

@end