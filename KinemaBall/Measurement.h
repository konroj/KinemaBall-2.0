//
//  Measurement.h
//  
//
//  Created by Konrad Roj on 02.08.2015.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Measurement : NSManagedObject

@property (nonatomic, retain) NSNumber * fps;
@property (nonatomic, retain) NSNumber * mass;
@property (nonatomic, retain) NSNumber * size;
@property (nonatomic, retain) NSString * frame;
@property (nonatomic, retain) NSString * framesPath;
@property (nonatomic, retain) NSString * positionsPath;
@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * maxSpeed;

@end
