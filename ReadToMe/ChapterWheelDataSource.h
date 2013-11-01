//
//  ChapterWheelDataSource.h
//  ReadToMe
//
//  Created by Vann-Campbell, Tyler on 10/8/13.
//  Copyright (c) 2013 Vann-Campbell, Tyler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDCircle.h"
#import "ChapterController.h"

@interface ChapterWheelDataSource : NSObject <CDCircleDataSource,CDCircleDelegate>

@property (strong) NSDictionary* chapters;
@property (weak) id<ChapterController> controller;
@property (weak) id<CDCircleDataSource> parentDataSource;

@end
