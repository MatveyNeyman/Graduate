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
                       photosKeys:nil
                        notes:@""];
}

// Designated initializer
- (instancetype)initWithName:(NSString *)name
                        type:(NSString *)type
                     address:(NSString *)address
                    location:(CLLocation *)location
                      rating:(NSInteger)rating
                       price:(NSInteger)price
                      photosKeys:(NSMutableArray<NSString *> *)photosKeys
                       notes:(NSString *)notes {
    self = [super init];
    if (self) {
        _name = name;
        _type = type;
        _address = address;
        _location = location;
        _rating = rating;
        _price = price;
        _photosKeys = photosKeys;
        _notes = notes;
        
        // Create NSUUID object and get its string representation
        //NSUUID *uuid = [[NSUUID alloc] init];
        //NSString *key = [uuid UUIDString];
        //_recordKey = key;
        
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
            self.photosKeys,
            self.notes];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.type forKey:@"type"];
    [aCoder encodeObject:self.address forKey:@"address"];
    [aCoder encodeObject:self.location forKey:@"location"];
    [aCoder encodeInteger:self.rating forKey:@"rating"];
    [aCoder encodeInteger:self.price forKey:@"price"];
    [aCoder encodeObject:self.photosKeys forKey:@"photosKeys"];
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
        _photosKeys = [aDecoder decodeObjectForKey:@"photosKeys"];
        _notes = [aDecoder decodeObjectForKey:@"notes"];
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    Record *record = (Record *)object;
    /*
    double latSelf = self.location.coordinate.latitude;
    double lonSelf = self.location.coordinate.longitude;
    double latRec = self.location.coordinate.latitude;
    double lonRec = self.location.coordinate.longitude;
    
    NSNumber *latitudeSelf = @(self.location.coordinate.latitude);
    NSNumber *longitudeSelf = @(self.location.coordinate.longitude);
    
    NSNumber *latitudeRecord = @(record.location.coordinate.latitude);
    NSNumber *longitudeRecord = @(record.location.coordinate.longitude);
    
    double fabs1 = fabs(self.location.coordinate.latitude - record.location.coordinate.latitude);
    double fabs2 = fabs(self.location.coordinate.longitude - record.location.coordinate.longitude);
    */
    if ([self.name isEqualToString:record.name] &&
        [self.type isEqualToString:record.type] &&
        [self.address isEqualToString:record.address] &&
        (fabs(self.location.coordinate.latitude - record.location.coordinate.latitude) < 0.000001) &&
        (fabs(self.location.coordinate.longitude - record.location.coordinate.longitude) < 0.000001) &&
        (self.rating == record.rating) &&
        (self.price == record.price) &&
        [self.photosKeys isEqualToArray:record.photosKeys] &&
        [self.notes isEqualToString:record.notes]) {
        return YES;
    } else {
        return NO;
    }
}

@end