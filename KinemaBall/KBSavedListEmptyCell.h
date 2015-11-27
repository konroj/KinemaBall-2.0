//
//  KBSavedListEmptyCell.h
//  KinemaBall
//
//  Created by Konrad Roj on 23.11.2015.
//  Copyright © 2015 Konrad Roj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KBSavedListEmptyCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *swipeImageView;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;

@end
