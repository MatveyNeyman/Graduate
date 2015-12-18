//
//  SharedData.h
//  MyCafe
//
//  Created by User on 12/17/15.
//  Copyright © 2015 Harman. All rights reserved.
//

//Singleton object for data passing

#import <Foundation/Foundation.h>
@class Record;

@interface SharedData : NSObject

@property (nonatomic, readonly) NSArray *listOfRecords;

+ (instancetype)sharedData;

- (void)addRecord:(Record *)record;
- (BOOL)saveList;

@end