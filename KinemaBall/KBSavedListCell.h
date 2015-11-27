//
//  KBSavedListCell.h
//  KinemaBall
//
//  Created by Konrad Roj on 23.11.2015.
//  Copyright © 2015 Konrad Roj. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SavedListCellDelegate <NSObject>

- (void)didSavedChanges:(id)sender;

@end

@interface KBSavedListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *massLabel;
@property (weak, nonatomic) IBOutlet UITextField *sizeTextField;
@property (weak, nonatomic) IBOutlet UITextField *massTextField;

@property (weak, nonatomic) id<SavedListCellDelegate> delegate;

- (void)setupWithMeasurement:(Measurement *)measure;

@end
