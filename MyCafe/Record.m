//
//  Record.m
//  MyCafe
//
//  Created by User on 12/17/15.
//  Copyright © 2015 Harman. All rights reserved.
//

#import "Record.h"

@interface Record () <NSCoding>

@end

@implementation Record

- (instancetype)init {
    return [self initWithName:@""
                         type:@""
                      address:@""
                     location:nil
                       rating:0
                        price:0
                       photos:nil
                        notes:@""];
}

// Designated initializer
- (instancetype)initWithName:(NSString *)name
                        type:(NSString *)type
                     address:(NSString *)address
                    location:(CLLocation *)location
                      rating:(NSInteger)rating
                       price:(NSInteger)price
                      photos:(NSMutableArray<UIImage *> *)photos
                       notes:(NSString *)notes {
    self = [super init];
    if (self) {
        self.name = name;
        self.type = type;
        self.address = address;
        self.location = location;
        self.rating = rating;
        self.price = price;
        self.photos = photos;
        self.notes = notes;
    }
    return self;
}

//Overriding NSObject's description method
- (NSString *)description {
    return [NSString stringWithFormat:@"%@, %@, %@, %@, %d, %d, %@, %@",
            self.name,
            self.type,
            self.address,
            self.location,
            (int) self.rating,
            (int) self.price,
            self.photos,
            self.notes];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.type forKey:@"type"];
    [aCoder encodeObject:self.address forKey:@"address"];
    [aCoder encodeObject:self.location forKey:@"location"];
    [aCoder encodeInteger:self.rating forKey:@"rating"];
    [aCoder encodeInteger:self.price forKey:@"price"];
    [aCoder encodeObject:self.photos forKey:@"photos"];
    [aCoder encodeObject:self.notes forKey:@"notes"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _name = [aDecoder decodeObjectForKey:@"name"];
        _type = [aDecoder decodeObjectForKey:@"type"];
        _address = [aDecoder decodeObjectForKey:@"address"];
        _location = [aDecoder decodeObjectForKey:@"location"];
        _rating = [aDecoder decodeIntegerForKey:@"rating"];
        _price = [aDecoder decodeIntegerForKey:@"price"];
        _photos = [aDecoder decodeObjectForKey:@"photos"];
        _notes = [aDecoder decodeObjectForKey:@"notes"];
    }
    return self;
}

@end