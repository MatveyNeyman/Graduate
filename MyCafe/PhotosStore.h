//
//  PhotosStore.h
//  MyCafe
//
//  Created by User on 12/23/15.
//  Copyright © 2015 Harman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PhotosStore : NSObject

+ (instancetype)photosStore;

- (void)setImage:(UIImage *)image forKey:(NSString *)key;
- (UIImage *)imageForKey:(NSString *)key;
- (void)deleteImageForKey:(NSString *)key;

@end
