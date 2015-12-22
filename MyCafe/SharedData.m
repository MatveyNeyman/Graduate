//
//  SharedData.m
//  MyCafe
//
//  Created by User on 12/17/15.
//  Copyright © 2015 Harman. All rights reserved.
//

#import "SharedData.h"

@interface SharedData ()

@property (nonatomic) NSMutableArray *privateList;

@end

@implementation SharedData

+ (instancetype)sharedData {
    static SharedData *sharedData;
    
    if (!sharedData) {
        sharedData = [[self alloc] init];
    }
    return sharedData;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _privateList = [NSKeyedUnarchiver unarchiveObjectWithFile:[self buildPath]];
        if (!_privateList) {
            _privateList = [NSMutableArray array];
        }
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
    [self.privateList removeObject:record];
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

@end