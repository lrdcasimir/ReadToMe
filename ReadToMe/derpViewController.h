//
//  derpViewController.h
//  ReadToMe
//
//  Created by Vann-Campbell, Tyler on 8/17/13.
//  Copyright (c) 2013 Vann-Campbell, Tyler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CDCircle.h"
#import "RadioClient.h"
#import "ChapterWheelDataSource.h"
#import "ChapterController.h"
#import "PlayerControls.h"

@interface derpViewController  : UIViewController <CDCircleDelegate,CDCircleDataSource,RadioClientDelegate,ChapterController>
@property UIView* circleContainer;
@property UIView* chapterCircleContainer;
@property UIPanGestureRecognizer* recognizer;
@property UISwipeGestureRecognizer* resetRecognizer;
@property UILabel* bookTitle;
@property UILabel* chapterTitle;
@property PlayerControls* controls;
@property NSDictionary* books;
@property ChapterWheelDataSource* chapterDataSource;
@property NSMutableArray* pathSegments;

@end
