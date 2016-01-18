//
//  ServerViewController.m
//  MyCafe
//
//  Created by User on 1/15/16.
//  Copyright © 2016 Harman. All rights reserved.
//

#import "ServerViewController.h"
#import <Parse/Parse.h>
#import "Record.h"
#import "PhotosStore.h"
#import "SharedData.h"

@interface ServerViewController () {
    UIImage *image;
    UIView *backgroundView;
    UIActivityIndicatorView *activityView;
    UITableViewCell *selectedCell;
}

@property (nonatomic) NSMutableArray<Record *> *entries;
@property (nonatomic) NSMutableArray<NSIndexPath *> *downloadingCellPaths;

@end

@implementation ServerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    CGFloat barHeight = self.navigationController.navigationBar.frame.size.height;
    backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height - barHeight)];
    backgroundView.backgroundColor = [UIColor lightGrayColor];
    backgroundView.alpha = 0.5;
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.color = [UIColor blackColor];
    CGPoint centerPoint = CGPointMake(backgroundView.center.x, backgroundView.center.y - barHeight);
    activityView.center = centerPoint;
    [activityView startAnimating];
    [backgroundView addSubview:activityView];
    [self.tableView addSubview:backgroundView];
    
    self.entries = [NSMutableArray array];
    [self getFromParse];
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageDownloaded:)
                                                 name:@"imageDownloaded"
                                               object:nil];
     */
    self.downloadingCellPaths = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.entries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ServerCell" forIndexPath:indexPath];
    cell.textLabel.text = self.entries[indexPath.row].name;
    cell.detailTextLabel.text = self.entries[indexPath.row].address;
    if ([self.downloadingCellPaths containsObject:indexPath]) {
        [self showActivityIndicatorForCell:cell atIndexPath:indexPath];
    }
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    Record *record = self.entries[indexPath.row];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *downloadAction = [UIAlertAction actionWithTitle:@"Download"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action) {
                                                            [self uploadRecord:record atIndexPath:indexPath];
                                                        }];
    [alert addAction:downloadAction];
    
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

- (void)getFromParse {
    PFQuery *query = [PFQuery queryWithClassName:@"RecordObject"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects) {
                //for (NSString *key in object[@"photosKeys"]) {
                //    [self findPhotoForKey:key];
                //}
                PFGeoPoint *point = object[@"point"];
                CLLocation *location;
                if ([point isKindOfClass:[NSNull class]]) {
                    location = nil;
                } else {
                    location = [[CLLocation alloc] initWithLatitude:point.latitude longitude:point.longitude];
                }
                
                PFObject *ratingObject = object[@"rating"];
                NSInteger rating;
                if ([ratingObject isKindOfClass:[NSNull class]]) {
                    rating = 0;
                } else {
                    rating = [object[@"rating"] intValue];
                }
                
                PFObject *priceObject = object[@"price"];
                NSInteger price;
                if ([priceObject isKindOfClass:[NSNull class]]) {
                    price = 0;
                } else {
                    price = [object[@"price"] intValue];
                }
                
                Record *record = [[Record alloc] initWithName:object[@"name"]
                                                         type:object[@"type"]
                                                      address:object[@"address"]
                                                     location:location
                                                       rating:rating
                                                        price:price
                                                   photosKeys:object[@"photosKeys"]
                                                        notes:object[@"notes"]];
                [self.entries addObject:record];
                
            }
            [backgroundView removeFromSuperview];
            [self.tableView reloadData];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

/*
- (UIImage *)findPhotoForKey:(NSString *)key {
    //dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    PFQuery *query = [PFQuery queryWithClassName:@"PhotoObject"];
    [query whereKey:@"photoName" equalTo:key];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            PFObject *photoObject = [objects firstObject];
            PFFile *photo = photoObject[@"photoFile"];
            NSData *imageData = [photo getData];
            image = [UIImage imageWithData:imageData];
            [[PhotosStore photosStore] setImage:image forKey:key];
            
            //[[NSNotificationCenter defaultCenter] postNotificationName:@"imageDownloaded"
              //                                                  object:self
               //                                               userInfo:@{@"searchString":stringForSearch}];
            //dispatch_semaphore_signal(semaphore);
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    //dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    //return image;
//}
*/

- (void)uploadRecord:(Record *)record atIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = selectedCell;
    if ([[SharedData sharedData].listOfRecords containsObject:record]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"This record is already exists in my list"
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self showActivityIndicatorForCell:cell atIndexPath:indexPath];
        //for (NSString *key in record.photosKeys) {
        for (int i = 0; i < record.photosKeys.count; i++) {
            NSLog(@"record.photosKeys.count %lu", (unsigned long)record.photosKeys.count);
            NSString *key = record.photosKeys[i];
            if (![[PhotosStore photosStore] imageForKey:key]) {
                PFQuery *query = [PFQuery queryWithClassName:@"PhotoObject"];
                [query whereKey:@"photoName" equalTo:key];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        PFObject *photoObject = [objects firstObject];
                        PFFile *photo = photoObject[@"photoFile"];
                        NSData *imageData = [photo getData];
                        image = [UIImage imageWithData:imageData];
                        if (image) {
                            [[PhotosStore photosStore] setImage:image forKey:key];
                        }
                    } else {
                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                    }
                    if (i == record.photosKeys.count - 1) {
                        [self dropActivityIndicatorForCell:cell atIndexPath:indexPath];
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Record has been succesfully added to my list"
                                                                                       message:nil
                                                                                preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                                style:UIAlertActionStyleDefault
                                                                              handler:^(UIAlertAction *action) {}];
                        [alert addAction:defaultAction];
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                }];
            }
        }
        [[SharedData sharedData] addRecord:record];
        /*
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Record has been succesfully added to my list"
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
         */
    }
}

-(void)showActivityIndicatorForCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    UIActivityIndicatorView *smallActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [smallActivityView startAnimating];
    cell.accessoryView = smallActivityView;
    [self.downloadingCellPaths addObject:indexPath];
}

-(void)dropActivityIndicatorForCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.accessoryView = nil;
    [self.downloadingCellPaths removeObject:indexPath];
}

/*
- (BOOL)isAlreadyExist {
    isExistOnDevice = NO;
 
    double latitude = self.record.location.coordinate.latitude;
    double longitude = self.record.location.coordinate.longitude;
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:latitude longitude:longitude];
    
    PFQuery *query = [PFQuery queryWithClassName:@"RecordObject"];
    [query whereKey:@"name" equalTo:self.record.name];
    [query whereKey:@"type" equalTo:self.record.type];
    [query whereKey:@"address" equalTo:self.record.address];
    [query whereKey:@"point" equalTo:point];
    [query whereKey:@"rating" equalTo:@(self.record.rating)];
    [query whereKey:@"price" equalTo:@(self.record.price)];
    //[query whereKey:@"photosKeys" equalTo:self.record.photosKeys];
    [query whereKey:@"notes" equalTo:self.record.notes];
    
    NSArray* scoreArray = [query findObjects];
    if ([scoreArray count] > 0) {
        for (PFObject *object in scoreArray) {
            if ([object[@"photosKeys"] isEqualToArray:self.record.photosKeys]) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"This record is already exists on server"
                                                                               message:nil
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                        style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction *action) {}];
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
                isExistOnDevice = YES;
            }
        }
    } else {
        isExistOnDevice = NO;
    }
    return isExistOnDevice;
}
*/

//- (void)imageDownloaded:(NSNotification *)notification {

 

@end
