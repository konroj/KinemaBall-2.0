//
//  KBSavedListViewController.m
//  KinemaBall
//
//  Created by Konrad Roj on 23.11.2015.
//  Copyright © 2015 Konrad Roj. All rights reserved.
//

#import "KBSavedListViewController.h"
#import "KBSavedListCell.h"
#import "KBSavedListEmptyCell.h"
#import "KBDetailViewController.h"

@interface KBSavedListViewController () <UITableViewDataSource, UITableViewDelegate, SavedListCellDelegate>
@property (strong, nonatomic) NSMutableArray *measurements;
@property (strong, nonatomic) NSMutableArray *images;
@property (strong, nonatomic) NSMutableArray *all;
@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation KBSavedListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Measurements", nil);
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
    
    self.measurements = [NSMutableArray arrayWithArray:[Measurement MR_findAll]];
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.measurements.count ?: 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.measurements.count) {
        KBSavedListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        cell.backgroundImageView.backgroundColor = [UIColor clearColor];
        cell.delegate = self;
        
        [cell setupWithMeasurement:self.measurements[indexPath.row]];
        return cell;
    } else {
        KBSavedListEmptyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Nothing" forIndexPath:indexPath];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[KBSavedListCell class]]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[KBSavedListCell class]]) {
        [self performSegueWithIdentifier:@"detail" sender:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Measurement *measurement = self.measurements[indexPath.row];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *framePath = [documentsPath stringByAppendingPathComponent:measurement.frame];
        NSString *framesPath = [documentsPath stringByAppendingPathComponent:measurement.framesPath];
        NSString *positionsPath = [documentsPath stringByAppendingPathComponent:measurement.positionsPath];
        NSString *fullGreyPath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"grayframes%@", measurement.framesPath]];
        
        NSError *error;
        BOOL success = [fileManager removeItemAtPath:framePath error:&error];
        if (success) {
            success = [fileManager removeItemAtPath:framesPath error:&error];
        }
        if (success) {
            success = [fileManager removeItemAtPath:positionsPath error:&error];
        }
        if (success) {
            success = [fileManager removeItemAtPath:fullGreyPath error:&error];
        }
        if (self.measurements.count && success) {
            [measurement MR_deleteEntity];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        }
        
        if (success) {
            if (self.measurements.count > 1) {
                [self.measurements removeObjectAtIndex:indexPath.row];
            } else {
                self.measurements = nil;
            }
            
            [tableView beginUpdates];
            if (self.measurements.count > 0) {
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            } else {
                [tableView reloadData];
            }
            [tableView endUpdates];
        } else {
            UIAlertView *removeSuccessFulAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
            [removeSuccessFulAlert show];
        }
        
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"detail"]) {
        KBDetailViewController *vc = [segue destinationViewController];
        NSIndexPath *index = (NSIndexPath *)sender;
        vc.date = [(Measurement *)self.measurements[index.row] time];
    }
}

- (void)didSavedChanges:(id)sender {
    self.measurements = [NSMutableArray arrayWithArray:[Measurement MR_findAll]];
    [self.tableView reloadData];
}

@end
