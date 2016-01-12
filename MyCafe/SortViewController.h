//
//  SortViewController.h
//  MyCafe
//
//  Created by User on 1/12/16.
//  Copyright © 2016 Harman. All rights reserved.
//

#import <UIKit/UIKit.h>

// Declare protocol for passing data back after sort descriptor has been set
@protocol SortDelegate <NSObject>
- (void)sortViewControllerDismissed:(NSSortDescriptor *)descriptor;
@end

@interface SortViewController : UIViewController
// Delegate property
@property (nonatomic, weak) id<SortDelegate> sortDelegate;
@end
