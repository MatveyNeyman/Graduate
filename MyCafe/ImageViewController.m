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
@property (strong, nonatomic) IBOutlet UIBarButtonItem *trashButton;

@end

@implementation ImageViewController

- (void)awakeFromNib {
    NSLog(@"Awake from nib image view controller started");
    NSLog(@"isEditingMode flag in the image view controller 'awake from nib' %hhd", self.isEditingMode);
    self.isEditingMode = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"isEditingMode flag in the image view controller 'view did load' %hhd", self.isEditingMode);
    if (!self.isEditingMode) {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.imageView.image = [[PhotosStore photosStore] imageForKey:self.startKey];
    index = [self.photosKeys indexOfObject:self.startKey];
}

- (IBAction)swipeRight:(id)sender {
    if (index >= 1) {
        --index;
        NSString *key = [self.photosKeys objectAtIndex:index];
        self.imageView.image = [[PhotosStore photosStore] imageForKey:key];
        [self animateFrom:kCATransitionFromLeft];
    } else {
        return;
    }
}

- (IBAction)swipeLeft:(id)sender {
    if (index < ([self.photosKeys count] - 1)) {
        ++index;
        NSString *key = [self.photosKeys objectAtIndex:index];
        self.imageView.image = [[PhotosStore photosStore] imageForKey:key];
        [self animateFrom:kCATransitionFromRight];
    } else {
        return;
    }
}

- (void)animateFrom:(NSString *)direction {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5f;
    //transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    transition.subtype = direction;
    [self.imageView.layer addAnimation:transition forKey:nil];
}

- (IBAction)trashButtonClicked:(id)sender {
    NSString *key = [self.photosKeys objectAtIndex:index];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete Photo"
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction *action) {
                                                             // Delete photo
                                                             [[PhotosStore photosStore] deleteImageForKey:key];
                                                             [self.photosKeys removeObjectAtIndex:index];
                                                             if (index == 0) {
                                                                 [self.navigationController popViewControllerAnimated:YES];
                                                             } else {
                                                                 NSString *newKey = [self.photosKeys objectAtIndex:--index];
                                                                 self.imageView.image = [[PhotosStore photosStore] imageForKey:newKey];
                                                             }
                                                         }];
    [alert addAction:deleteAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {}];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
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
