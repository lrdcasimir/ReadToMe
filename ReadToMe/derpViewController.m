//
//  derpViewController.m
//  ReadToMe
//
//  Created by Vann-Campbell, Tyler on 8/17/13.
//  Copyright (c) 2013 Vann-Campbell, Tyler. All rights reserved.
//

#import "derpViewController.h"
#import "CDCircle.h"
#import "CDCircleThumb.h"
#import "CDIconView.h"
#import "CDCircleOverlayView.h"
@interface derpViewController ()

@end

@implementation derpViewController

CGRect initialCirclePosition;
CDCircle* circleMenu;
RadioClient* radioClient;
BOOL bookTitleDisplayed = NO;
BOOL chapterDisplayed = NO;
CGPoint initialBookTitleCenterPoint;


- (void) initCircleMenu { 
    NSUInteger numberOfBooks = [[self.books allKeys] count];
    circleMenu = [[CDCircle alloc] initWithFrame:CGRectMake(20, 0, 280, 280) numberOfSegments:numberOfBooks ringWidth:100];
    circleMenu.delegate = self;
    circleMenu.dataSource = self;
    CDCircleOverlayView *overlay = [[CDCircleOverlayView alloc] initWithCircle:circleMenu];
    
    circleMenu.circleColor = [UIColor colorWithRed:.8 green:0.85 blue:1 alpha:1];
    [self.circleContainer addSubview:circleMenu];
    [self.circleContainer addSubview:overlay];
    [self.view addSubview:self.circleContainer];
    for(CDCircleThumb *thumb in circleMenu.thumbs){
        [thumb setGradientColors: [NSArray arrayWithObjects: [UIColor blueColor], nil]];
        
        thumb.gradientFill = YES;
        //UILabel *label = [[UILabel alloc] initWithFrame:thumb.iconView.frame];
        //label.text = @"This is a test";
        //[thumb addSubview:label];
        
        
    }
    
    self.recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panning:)];
    self.resetRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(resetView:)];
    self.resetRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.chapterDataSource = [[ChapterWheelDataSource alloc] init];
    self.chapterDataSource.controller = self;
    self.chapterDataSource.parentDataSource = self;
    initialCirclePosition = CGRectMake(0, 40, 280, 280);
	// Do any additional setup after loading the view, typically from a nib.
    radioClient = [[RadioClient alloc] init];
    radioClient.delegate = self;
    [radioClient discoverRadioLister]; //later
    
    
    self.circleContainer = [[UIView alloc] initWithFrame:initialCirclePosition];
    self.chapterTitle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.circleContainer.frame), CGRectGetMinY(self.circleContainer.frame) -100, 280, 100)];
    self.controls = [[[NSBundle mainBundle] loadNibNamed:@"controls" owner:self options:nil] objectAtIndex:0];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void) circle:(CDCircle *)circle didMoveToSegment:(NSInteger)segment thumb:(CDCircleThumb *)thumb
{
    if([[self.books allKeys] objectAtIndex:segment] != nil){
        [self displayBookTitle:[[self.books allKeys] objectAtIndex:segment]] ;
    }
}

-(void) displayBookTitle:(NSString*)title{
    self.pathSegments = [NSMutableArray arrayWithArray:@[title]];
    [self.chapterCircleContainer removeFromSuperview];
    [self.bookTitle removeFromSuperview];
    NSDictionary* chapters = [self.books objectForKey:title];
    if(chapters == nil){
        return;
    }
    
    self.chapterDataSource.chapters = chapters;
    CDCircle* chapterCircleMenu = [[CDCircle alloc] initWithFrame:CGRectMake(20, 0, 280, 280) numberOfSegments:[[chapters allKeys] count] ringWidth:100];
    chapterCircleMenu.circleColor = circleMenu.circleColor;
    CDCircleOverlayView* overlay = [[CDCircleOverlayView alloc] initWithCircle:chapterCircleMenu];
    self.bookTitle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.circleContainer.frame), CGRectGetMinY(self.circleContainer.frame) -100, 280, 100)];
    chapterCircleMenu.dataSource = self.chapterDataSource;
    chapterCircleMenu.delegate = self.chapterDataSource;
    
    
    
    self.chapterCircleContainer = [[UIView alloc] initWithFrame:CGRectMake(
                                                                           CGRectGetMinX(self.circleContainer.frame),
                                                                           CGRectGetMinY(self.bookTitle.frame) - 280,
                                                                           CGRectGetWidth(initialCirclePosition),
                                                                           CGRectGetHeight(initialCirclePosition))];
    [self.chapterCircleContainer addSubview:chapterCircleMenu];
    [self.chapterCircleContainer addSubview:overlay];
    [self.view addSubview:self.chapterCircleContainer];
    if (bookTitleDisplayed) {
        return [self hideBookTitle:title];
    }
    
    initialBookTitleCenterPoint = self.bookTitle.center;
    self.bookTitle.text = title;
    self.bookTitle.font = [UIFont fontWithName:@"Helvetica Neue" size:26];
    
    [self.view insertSubview:self.bookTitle belowSubview:self.circleContainer];
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
        self.chapterCircleContainer.center = CGPointMake(self.chapterCircleContainer.center.x, self.chapterCircleContainer.center.y + 100);
        self.bookTitle.center = CGPointMake(self.bookTitle.center.x, self.bookTitle.center.y + 100);
        self.circleContainer.center = CGPointMake(self.circleContainer.center.x, self.circleContainer.center.y +100 );
    
    } completion:^(BOOL finished){
        [self.view addGestureRecognizer:self.recognizer];
    }];
    bookTitleDisplayed = YES;
}

-(void) hideBookTitle:(NSString*)nextTitle {
    [self.chapterCircleContainer removeFromSuperview];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
        self.bookTitle.center = CGPointMake(self.bookTitle.center.x, 20);
        self.circleContainer.center = CGPointMake(self.circleContainer.center.x, 180);
    }completion:^(BOOL finished){
        bookTitleDisplayed = NO;
        [self.bookTitle removeFromSuperview];
        [self.view removeGestureRecognizer:self.recognizer];
        if(nextTitle != nil){
            [self displayBookTitle:nextTitle];
        }
        
    }];
    
}

-(void) hideChapter:(NSString*)nextChapter {
    [UIView animateWithDuration:0.3 animations:^(void){
        self.controls.center = CGPointMake(self.controls.center.x, -10);
        self.chapterTitle.center = CGPointMake(self.chapterTitle.center.x, 0);
        self.chapterCircleContainer.center = CGPointMake(self.chapterCircleContainer.center.x, 10);
        self.bookTitle.center = CGPointMake(self.bookTitle.center.x,
                                            335);
        
    }
    completion:^(BOOL finished) {
        chapterDisplayed = NO;
        [self displayChapter:nextChapter];
    }];
}

-(void) displayChapters {
    
    
    [self.view removeGestureRecognizer:self.recognizer];
    [self.view addGestureRecognizer:self.resetRecognizer];

    [UIView animateWithDuration:0.5 animations:^(void){
        
        self.bookTitle.center = CGPointMake(self.bookTitle.center.x,
                                            335);
        self.chapterCircleContainer.center = CGPointMake(
                                                         self.chapterCircleContainer.center.x,
                                                         self.bookTitle.center.y - 180);
        self.circleContainer.frame =
        CGRectMake(
                   CGRectGetMinX(self.circleContainer.frame),
                   CGRectGetMaxY(self.bookTitle.frame),
                   CGRectGetWidth(self.circleContainer.frame),
                   CGRectGetHeight(self.circleContainer.frame));
    }];
}

-(UIImage*) circle:(CDCircle *)circle iconForThumbAtRow:(NSInteger)row
{
    return [UIImage imageNamed:@"96-book.png"];
}

-(void) radioDiscovered:(NSString *)host{
    NSLog(@"radio discovered %@", host);
    [radioClient getListFromRadio];
}

     
     
-(void) radioRespondedWithJson:(NSString *)response{
    NSLog(@"JSON! %@", response);
    NSDictionary* jsonParsed = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"PARSED! %@", jsonParsed);
    if(jsonParsed == nil){
        [radioClient getListFromRadio];
    } else {
        self.books = [jsonParsed objectForKey:@"./books"];
        [self initCircleMenu];
    }
}

-(IBAction)panning:(id)sender{
    
    
    float y = [self.recognizer translationInView:self.view].y;
    NSLog(@"panning %f", y);
    if(y>0 && y<330 && self.recognizer.state != UIGestureRecognizerStateEnded){
        
        self.bookTitle.center = CGPointMake(self.bookTitle.center.x,
                                            y+15);
        self.chapterCircleContainer.frame = CGRectMake(
            CGRectGetMinX(self.chapterCircleContainer.frame),
            CGRectGetMinY(self.bookTitle.frame)
                 - CGRectGetHeight(self.chapterCircleContainer.frame) - 20,
        CGRectGetWidth(self.chapterCircleContainer.frame),
        CGRectGetHeight(self.chapterCircleContainer.frame)
        );
        self.circleContainer.frame =
        CGRectMake(
                                CGRectGetMinX(self.circleContainer.frame),
                                CGRectGetMaxY(self.bookTitle.frame),
                                CGRectGetWidth(self.circleContainer.frame),
                                CGRectGetHeight(self.circleContainer.frame));
    }
    
    if(y>180 && self.recognizer.state == UIGestureRecognizerStateEnded){
        [self displayChapters];
        
    } else if ( self.recognizer.state == UIGestureRecognizerStateEnded){
        [UIView animateWithDuration:0.3 animations: ^(void) {
            self.bookTitle.center = initialBookTitleCenterPoint;
            [self.chapterCircleContainer removeFromSuperview];
            self.circleContainer.frame =
            CGRectMake(
                       CGRectGetMinX(self.circleContainer.frame),
                       CGRectGetMaxY(self.bookTitle.frame),
                       CGRectGetWidth(self.circleContainer.frame),
                       CGRectGetHeight(self.circleContainer.frame));
            
        }];
    }
   
}


-(void) displayChapter:(NSString *)chapterTitle{
    if(chapterDisplayed){
        [self hideChapter:chapterTitle];
    }
    
    if([self.pathSegments count] > 1){
        [self.pathSegments removeLastObject];
    }
    [self.pathSegments addObject:chapterTitle];
    self.chapterTitle.text = chapterTitle;
    
    self.chapterTitle.font = [UIFont fontWithName:@"Hevetica Neue" size:16];
    float total_y_offset = CGRectGetHeight(self.chapterTitle.frame) + CGRectGetHeight(self.controls.frame);
    float title_y_offset = CGRectGetHeight(self.chapterTitle.frame);
    self.chapterTitle.frame = CGRectMake(CGRectGetMinX(self.chapterCircleContainer.frame),
                                         CGRectGetMinY(self.chapterCircleContainer.frame) - title_y_offset ,
                                         CGRectGetWidth( self.chapterTitle.frame ),
                                         CGRectGetHeight( self.chapterTitle.frame));
    self.controls.frame = CGRectMake(
                                     CGRectGetMinX(self.chapterCircleContainer.frame),
                                     CGRectGetMinY(self.chapterCircleContainer.frame) - total_y_offset,
                                     CGRectGetWidth(self.controls.frame),
                                     CGRectGetHeight(self.controls.frame));
    [self.view addSubview:self.chapterTitle];
    [self.view addSubview:self.controls];
    [self.controls.playButton addTarget:self action:@selector(playChapter:) forControlEvents:UIControlEventTouchDown];
    [self.controls.pauseButton addTarget:self action:@selector(pauseChapter:) forControlEvents:UIControlEventTouchDown];
    
    [UIView animateWithDuration:0.3 animations:^(void){
        self.chapterTitle.frame             = CGRectMake(CGRectGetMinX(self.chapterCircleContainer.frame),
                                                         CGRectGetMinY(self.chapterCircleContainer.frame) ,
                                                         CGRectGetWidth( self.chapterTitle.frame ),
                                                         CGRectGetHeight( self.chapterTitle.frame));
        self.controls.frame                 = CGRectMake(
                                                         CGRectGetMinX(self.chapterCircleContainer.frame),
                                                         CGRectGetMinY(self.chapterCircleContainer.frame) + total_y_offset - title_y_offset,
                                                         CGRectGetWidth(self.chapterCircleContainer.frame),
                                                         CGRectGetHeight(self.controls.frame));
        self.chapterCircleContainer.frame   = CGRectMake(
                                                        CGRectGetMinX(self.chapterCircleContainer.frame),
                                                         CGRectGetMinY(self.chapterCircleContainer.frame) + total_y_offset,
                                                         CGRectGetWidth(self.chapterCircleContainer.frame),
                                                         CGRectGetHeight(self.chapterCircleContainer.frame));
        self.bookTitle.center = CGPointMake(self.bookTitle.center.x, self.bookTitle.center.y
                                            + total_y_offset);
        
    }];
    chapterDisplayed = YES;
    
}

-(IBAction) playChapter:(id)sender {
    [radioClient requestTrack:[NSString pathWithComponents:self.pathSegments]];
    self.controls.playButton.hidden = YES;
    self.controls.pauseButton.hidden = NO;
    self.controls.pauseButton.userInteractionEnabled = YES;
    self.controls.playButton.userInteractionEnabled = NO;
}


-(IBAction) pauseChapter:(id)sender {
    [radioClient pause];
    self.controls.pauseButton.hidden = YES;
    self.controls.playButton.hidden = NO;
    self.controls.pauseButton.userInteractionEnabled = NO;
    self.controls.playButton.userInteractionEnabled = YES;
}

-(IBAction)resetView:(id)sender{
    [self.chapterCircleContainer removeFromSuperview];
    [self.bookTitle removeFromSuperview];
    [self.controls removeFromSuperview];
    [self.chapterTitle removeFromSuperview];
    [self hideBookTitle:nil];
    [self.view addGestureRecognizer:self.recognizer];
    [self.view removeGestureRecognizer:self.resetRecognizer];
    
}
     
@end
