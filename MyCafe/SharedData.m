//
//  SharedData.m
//  MyCafe
//
//  Created by User on 12/17/15.
//  Copyright © 2015 Harman. All rights reserved.
//

#import "SharedData.h"
#import "PhotosStore.h"

@interface SharedData ()

@property (nonatomic) NSMutableArray *privateList;

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

@end