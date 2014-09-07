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
#import "IDZAudioPlayer.h"

@interface derpViewController  : UIViewController <CDCircleDelegate,CDCircleDataSource,RadioClientDelegate,ChapterController>
@property (nonatomic,strong) IBOutlet UILabel* discoveryStatus;
@property (nonatomic,strong) IBOutlet UIActivityIndicatorView* spinner;
@property UIView* circleContainer;
@property UIView* chapterCircleContainer;
@property CDCircle* chapterCircleMenu;
@property CDCircleOverlayView* chapterCircleOverlay;
@property UIPanGestureRecognizer* recognizer;
@property UISwipeGestureRecognizer* resetRecognizer;
@property UILabel* bookTitle;
@property UILabel* chapterTitle;
@property PlayerControls* controls;
@property NSDictionary* books;
@property ChapterWheelDataSource* chapterDataSource;
@property NSMutableArray* pathSegments;
@property (nonatomic,strong) id<IDZAudioPlayer> player;
@property (nonatomic,strong) NSTimer* statusTimer;

@end
