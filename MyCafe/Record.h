//
//  Record.h
//  MyCafe
//
//  Created by User on 12/17/15.
//  Copyright © 2015 Harman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface Record : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *address;
@property (nonatomic) CLLocation *location;
@property (nonatomic) NSInteger rating;
@property (nonatomic) NSInteger price;
@property (nonatomic) NSMutableArray<NSString *> *photosKeys;
//@property (nonatomic) NSMutableArray<UIImage *> *photos;
@property (nonatomic, copy) NSString *notes;

//@property (nonatomic, copy) NSString *recordKey;


- (instancetype)initWithName:(NSString *)name
                        type:(NSString *)type
                     address:(NSString *)address
                    location:(CLLocation *)location
                      rating:(NSInteger)rating
                       price:(NSInteger)price
                      photosKeys:(NSMutableArray<NSString *> *) photosKeys
                       notes:(NSString *)notes;

- (BOOL)isEqual:(id)object;

@end