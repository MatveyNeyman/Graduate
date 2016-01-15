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
}

@property (nonatomic) NSMutableArray<Record *> *entries;

@end

@implementation ServerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    self.entries = [NSMutableArray array];
    [self getFromParse];
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageDownloaded:)
                                                 name:@"imageDownloaded"
                                               object:nil];
     */
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
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    Record *record = self.entries[indexPath.row];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *uploadAction = [UIAlertAction actionWithTitle:@"Upload"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action) {
                                                            [self uploadRecord:record];
                                                        }];
    [alert addAction:uploadAction];
    
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
                CLLocation *location = [[CLLocation alloc] initWithLatitude:point.latitude longitude:point.longitude];
                Record *record = [[Record alloc] initWithName:object[@"name"]
                                                         type:object[@"type"]
                                                      address:object[@"address"]
                                                     location:location
                                                       rating:[object[@"rating"] intValue]
                                                        price:[object[@"price"] intValue]
                                                   photosKeys:object[@"photosKeys"]
                                                        notes:object[@"notes"]];
                [self.entries addObject:record];
                
            }
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

- (void)uploadRecord:(Record *)record {
    
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
        for (NSString *key in record.photosKeys) {
            if (![[PhotosStore photosStore] imageForKey:key]) {
                PFQuery *query = [PFQuery queryWithClassName:@"PhotoObject"];
                [query whereKey:@"photoName" equalTo:key];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        PFObject *photoObject = [objects firstObject];
                        PFFile *photo = photoObject[@"photoFile"];
                        NSData *imageData = [photo getData];
                        image = [UIImage imageWithData:imageData];
                        [[PhotosStore photosStore] setImage:image forKey:key];
                    } else {
                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                    }
                }];
            }
        }
        [[SharedData sharedData] addRecord:record];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Record has been succesfully added to my list"
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
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
