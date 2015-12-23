//
//  SharedData.h
//  MyCafe
//
//  Created by User on 12/17/15.
//  Copyright © 2015 Harman. All rights reserved.
//

//Singleton object for data passing

#import <Foundation/Foundation.h>
#import "Record.h"

@interface SharedData : NSObject

@property (nonatomic, readonly) NSArray *listOfRecords;

+ (instancetype)sharedData;

- (void)addRecord:(Record *)record;
- (void)removeRecord:(Record *)record;
- (BOOL)saveList;

@end