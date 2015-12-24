//
//  ImageViewController.m
//  MyCafe
//
//  Created by User on 12/24/15.
//  Copyright © 2015 Harman. All rights reserved.
//

#import "ImageViewController.h"
#import "PhotosStore.h"

@interface ImageViewController ()
{
    NSUInteger index;
}

@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //self.imageView.image = self.image;
    self.imageView.image = [[PhotosStore photosStore] imageForKey:self.startKey];
    index = [self.photosKeys indexOfObject:self.startKey];
}

- (IBAction)swipeRight:(id)sender {
    if (index >= 1) {
        --index;
        NSString *key = [self.photosKeys objectAtIndex:index];
        self.imageView.image = [[PhotosStore photosStore] imageForKey:key];
        
        CATransition *transition = [CATransition animation];
        transition.duration = 0.5f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        transition.type = kCATransitionFromLeft;
        [self.imageView.layer addAnimation:transition forKey:nil];
        
    } else {
        return;
    }
}

- (IBAction)swipeLeft:(id)sender {
    if (index < ([self.photosKeys count] - 1)) {
        ++index;
        NSString *key = [self.photosKeys objectAtIndex:index];
        self.imageView.image = [[PhotosStore photosStore] imageForKey:key];
        
        CATransition *transition = [CATransition animation];
        transition.duration = 0.5f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFromRight;
        [self.imageView.layer addAnimation:transition forKey:nil];
        
    } else {
        return;
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
