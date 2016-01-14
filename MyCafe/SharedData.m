//
//  SharedData.m
//  MyCafe
//
//  Created by User on 12/17/15.
//  Copyright © 2015 Harman. All rights reserved.
//

#import "SharedData.h"
#import "PhotosStore.h"

@interface SharedData () <CLLocationManagerDelegate>

@property (nonatomic) NSMutableArray *privateList;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;

@end

@implementation SharedData

+ (instancetype)sharedData {
    static SharedData *sharedData;
    //if (!sharedData) {
    //    sharedData = [[self alloc] initPrivate];
    //}
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedData = [[self alloc] initPrivate];
    });
    return sharedData;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use +[SharedData sharedData]" userInfo:nil];
    return nil;
}

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        _privateList = [NSKeyedUnarchiver unarchiveObjectWithFile:[self buildPath]];
        if (!_privateList) {
            _privateList = [NSMutableArray array];
        }
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        [_locationManager requestWhenInUseAuthorization];
        _currentLocation = self.locationManager.location;
    }
    return self;
}

// Overriding getter method for public list
- (NSArray *)listOfRecords {
    return self.privateList;
}

- (void)addRecord:(Record *)record {
    [self.privateList addObject:record];
}

- (void)removeRecord:(Record *)record {
    for (NSString *key in record.photosKeys) {
        [[PhotosStore photosStore] deleteImageForKey:key];
    }
    [self.privateList removeObjectIdenticalTo:record];
}

- (void)replaceRecord:(Record *)oldRecord withRecord:(Record *)newRecord {
    NSUInteger index = [self.privateList indexOfObject:oldRecord];
    [self.privateList replaceObjectAtIndex:index withObject:newRecord];
}

- (NSString *)buildPath {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories firstObject];
    return [documentDirectory stringByAppendingPathComponent:@"list.archive"];
}

- (BOOL)saveList {
    NSString *path = [self buildPath];
    return [NSKeyedArchiver archiveRootObject:self.privateList toFile:path];
}

- (NSString *)distanceToRecord:(Record *)record {
    NSString *distanceString;
    if (record.location) {
        CLLocationDistance distance = [record.location distanceFromLocation:self.currentLocation];
        if (distance > 0 && distance <= 950) {
            NSInteger roundedDistanceTo50 = (NSInteger)ceil(distance / 50) * 50;
            distanceString = [NSString stringWithFormat:@"%ld m", (long)roundedDistanceTo50];
        }
        if (distance > 950 && distance <= 9900) {
            double roundedDistanceTo100 = (NSInteger)ceil(distance / 100);
            roundedDistanceTo100 = roundedDistanceTo100 * 100 / 1000;
            distanceString = [NSString stringWithFormat:@"%.1f km", roundedDistanceTo100];
        }
        if (distance > 9900) {
            NSInteger roundedDistanceTo1000 = (NSInteger)ceil(distance / 1000);
            distanceString = [NSString stringWithFormat:@"%ld km", (long)roundedDistanceTo1000];
        }
    } else {
        distanceString = @"";
    }
    return distanceString;
}

- (void)updateLocation {
    self.currentLocation = self.locationManager.location;
}

@end