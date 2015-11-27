//
//  KBSavedListCell.m
//  KinemaBall
//
//  Created by Konrad Roj on 23.11.2015.
//  Copyright © 2015 Konrad Roj. All rights reserved.
//

#import "KBSavedListCell.h"
#import <MagicalRecord/NSManagedObjectContext+MagicalSaves.h>

@interface KBSavedListCell() <UITextFieldDelegate>
@property (strong, nonatomic) Measurement *measurement;

@end

@implementation KBSavedListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.massLabel.text = NSLocalizedString(@"Mass", nil);
    self.sizeLabel.text = NSLocalizedString(@"Object radius", nil);
    
    self.sizeTextField.placeholder = NSLocalizedString(@"enter mass", nil);
    self.massTextField.placeholder = NSLocalizedString(@"enter radius", nil);
    
    self.sizeTextField.keyboardType = UIKeyboardTypeDecimalPad;
    self.massTextField.keyboardType = UIKeyboardTypeDecimalPad;
    
    self.sizeTextField.delegate = self;
    self.massTextField.delegate = self;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *currentText = [[textField text] stringByReplacingOccurrencesOfString:@"m" withString:@""];
    currentText = [currentText stringByReplacingOccurrencesOfString:@"g" withString:@""];
    
    if ([textField isEqual:self.sizeTextField]) {
        NSMutableString *newText = [NSMutableString stringWithString:currentText];
        if (newText.length || ![string isEqualToString:@""]) {
            [newText replaceCharactersInRange:NSMakeRange(range.location == 0 ? range.location : range.location - 1, range.length) withString:string];
        }
        [newText appendString:@"m"];
        [textField setText:newText];
        return NO;
    } else {
        NSMutableString *newText = [NSMutableString stringWithString:currentText];
        if (newText.length || ![string isEqualToString:@""]) {
            [newText replaceCharactersInRange:NSMakeRange(range.location == 0 ? range.location : range.location - 1, range.length) withString:string];
        }
        [newText appendString:@"g"];
        [textField setText:newText];

        return NO;
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.measurement.mass = @([self.massTextField.text stringByReplacingOccurrencesOfString:@"g" withString:@""].doubleValue);
    self.measurement.size = @([self.sizeTextField.text stringByReplacingOccurrencesOfString:@"m" withString:@""].doubleValue);
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        Measurement *measurement = [Measurement MR_createEntityInContext:localContext];
        
        measurement.mass = self.measurement.mass;
        measurement.size = self.measurement.size;
        measurement.fps = self.measurement.fps;
        measurement.frame = self.measurement.frame;
        measurement.framesPath = self.measurement.framesPath;
        measurement.positionsPath = self.measurement.positionsPath;
        measurement.time = self.measurement.time;
        measurement.title = self.measurement.title;
        measurement.maxSpeed = self.measurement.maxSpeed;
        
        [self.measurement MR_deleteEntityInContext:localContext];
    } completion:^(BOOL contextDidSave, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(didSavedChanges:)]) {
            [self.delegate didSavedChanges:self];
        }
    }];
}

- (void)setupWithMeasurement:(Measurement *)measure {
    self.measurement = measure;
    self.label.text = measure.time;
    self.backgroundImageView.image = [self loadImage:measure.frame];
    self.massTextField.text = [NSString stringWithFormat:@"%@g", measure.mass];
    self.sizeTextField.text = [NSString stringWithFormat:@"%@m", measure.size];
}

- (UIImage *)loadImage:(NSString *)imageName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", imageName]];
    return [UIImage imageWithContentsOfFile:fullPath];
}

@end
