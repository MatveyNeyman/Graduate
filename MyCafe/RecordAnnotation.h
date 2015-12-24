//
//  RecordAnnotation.h
//  MyCafe
//
//  Created by User on 12/24/15.
//  Copyright © 2015 Harman. All rights reserved.
//

#import <MapKit/MapKit.h>
@class Record;

@interface RecordAnnotation : MKPointAnnotation

@property (nonatomic) Record *record;

@end
