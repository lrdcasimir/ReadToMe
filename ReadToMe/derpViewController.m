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
#import "IDZOggVorbisFileDecoder.h"
#import "IDZAQAudioPlayer.h"

#include <stdio.h>
#include <sys/stat.h>
@interface derpViewController ()

@end

@implementation derpViewController
@synthesize player = mPlayer;

CGRect initialCirclePosition;
CDCircle* circleMenu;

RadioClient* radioClient;

BOOL bookTitleDisplayed = NO;
BOOL chapterDisplayed = NO;
bool streamStarted = NO;
bool streamCancelled = NO;
CGPoint initialBookTitleCenterPoint;
CGRect initialChapterTitleFrame;


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
    initialChapterTitleFrame = CGRectMake(CGRectGetMinX(self.circleContainer.frame), CGRectGetMinY(self.circleContainer.frame) -135, 280, 50);
	// Do any additional setup after loading the view, typically from a nib.
    radioClient = [[RadioClient alloc] init];
    radioClient.delegate = self;
    [radioClient discoverRadioLister]; //later
    
    
    self.circleContainer = [[UIView alloc] initWithFrame:initialCirclePosition];
    self.chapterTitle = [[UILabel alloc] initWithFrame: initialChapterTitleFrame];
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
    chapterDisplayed = NO;
    self.pathSegments = [NSMutableArray arrayWithArray:@[title]];
    NSLog(@"chapter title center y %f", self.chapterTitle.center.y);
    NSLog(@"book title Chapter center y %f", self.chapterCircleContainer.center.y);
    [self.controls removeFromSuperview];
    [self.chapterTitle removeFromSuperview];
    [self.bookTitle removeFromSuperview];
    
    self.controls.hidden = YES;
    self.chapterTitle.hidden = YES;
    NSDictionary* chapters = [self.books objectForKey:title];
    if(chapters == nil){
        return;
    }
    
    self.chapterDataSource.chapters = chapters;
    [self.chapterCircleMenu removeFromSuperview];
    self.chapterCircleMenu = [[CDCircle alloc] initWithFrame:CGRectMake(20, 0, 280, 280) numberOfSegments:[[chapters allKeys] count] ringWidth:100];
    self.chapterCircleMenu.circleColor = circleMenu.circleColor;
    [self.chapterCircleOverlay removeFromSuperview];
    self.chapterCircleOverlay  = [[CDCircleOverlayView alloc] initWithCircle:self.chapterCircleMenu];
    
    self.bookTitle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.circleContainer.frame), CGRectGetMinY(self.circleContainer.frame) -100, 280, 100)];
    self.chapterCircleMenu.dataSource = self.chapterDataSource;
    self.chapterCircleMenu.delegate = self.chapterDataSource;
    [self.chapterCircleMenu addSubview: self.chapterCircleOverlay];
    for(CDCircleThumb* thumb in self.chapterCircleMenu.thumbs){
        [thumb setGradientColors:@[[UIColor blueColor], [UIColor grayColor]]];
        [thumb setGradientFill:YES];
    }
    
    
    self.chapterCircleContainer = [[UIView alloc] initWithFrame:CGRectMake(
                                                                           CGRectGetMinX(self.circleContainer.frame),
                                                                           CGRectGetMinY(self.bookTitle.frame) - 300,
                                                                           CGRectGetWidth(initialCirclePosition),
                                                                           CGRectGetHeight(initialCirclePosition))];
    [self.chapterCircleContainer addSubview:self.chapterCircleMenu];
    [self.chapterCircleContainer addSubview:self.chapterCircleOverlay];
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
    chapterDisplayed =NO;
    [self.chapterCircleContainer removeFromSuperview];
    self.chapterTitle.frame = initialChapterTitleFrame;
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
    float control_offset = CGRectGetHeight(self.controls.frame);
    float title_offset = CGRectGetHeight(self.controls.frame);
    
    [UIView animateWithDuration:0.3 animations:^(void){
        self.controls.frame = CGRectMake(
                                         CGRectGetMinX(self.controls.frame),
                                         CGRectGetMinY(self.controls.frame) -
                                         (control_offset + title_offset),
                                         CGRectGetWidth(self.controls.frame),
                                         CGRectGetHeight(self.controls.frame));
        self.chapterTitle.frame = CGRectMake(
                                             CGRectGetMinX(self.chapterTitle.frame),
                                             CGRectGetMinY(self.chapterTitle.frame) -
                                             (control_offset + title_offset ),
                                             CGRectGetWidth(self.chapterTitle.frame),
                                             CGRectGetHeight(self.chapterTitle.frame));
        
        self.chapterCircleContainer.frame = CGRectMake(
                                               CGRectGetMinX(self.chapterCircleContainer.frame),
                                               CGRectGetMinY(self.chapterCircleContainer.frame) -
                                               (control_offset + title_offset ),
                                               CGRectGetWidth(self.chapterCircleContainer.frame),
                                               CGRectGetHeight(self.chapterCircleContainer.frame));
        self.bookTitle.frame = CGRectMake(
            CGRectGetMinX(self.bookTitle.frame),
            CGRectGetMaxY(self.chapterCircleContainer.frame),
            CGRectGetWidth(self.bookTitle.frame),
            CGRectGetHeight(self.bookTitle.frame));
        self.circleContainer.frame = CGRectMake(
            CGRectGetMinX(self.circleContainer.frame),
            CGRectGetMaxY(self.bookTitle.frame),
            CGRectGetWidth(self.circleContainer.frame),
            CGRectGetHeight(self.circleContainer.frame));
        
    }
    completion:^(BOOL finished) {
        chapterDisplayed = NO;
        [self.controls removeFromSuperview];
        [self.chapterTitle removeFromSuperview];
        
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
        NSLog(@"Chapter center y %f", self.chapterCircleContainer.center.y);
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
    return [UIImage imageNamed:@"glyphicons_071_book.png"];
}

-(void) radioDiscovered:(NSString *)host{
    self.discoveryStatus.text = @"Finding books...";
    [radioClient getListFromRadio];
}

     
     
-(void) radioRespondedWithJson:(NSString *)response{
    [UIView animateWithDuration: 0.5  animations:^(){
        self.spinner.alpha = 0;
        self.discoveryStatus.alpha = 0;
    }];
    NSDictionary* jsonParsed = nil;
    NSLog(@"JSON! %@", response);
    if(response != nil){
        jsonParsed = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"PARSED! %@", jsonParsed);
    }
    
    if(jsonParsed == nil){
        [radioClient getListFromRadio];
    } else {
        self.books = [jsonParsed objectForKey:@"./books"];
        [self initCircleMenu];
    }
}

-(void) radioRespondedWithStream:(NSString *)outputFile bytesRead:(NSUInteger)bytesRead {
    if(streamCancelled){
        return;
    }
    NSLog(@"%lu bytes read\n", (unsigned long)bytesRead);
    self.controls.bytesLabel.text = [NSString stringWithFormat:@"%ld bytes",(unsigned long) bytesRead];
    int chapfd = open([outputFile cStringUsingEncoding:NSUTF8StringEncoding], O_RDONLY);
    struct stat filestat;
    filestat.st_size = 0;
    fstat(chapfd, &filestat);
    NSLog(@"file bytes %lldl", filestat.st_size);
    if (100000 < filestat.st_size && !streamStarted) {
        NSURL* url = [NSURL fileURLWithPath:outputFile];
        NSError* error;
        IDZOggVorbisFileDecoder* decoder = [[IDZOggVorbisFileDecoder alloc] initWithContentsOfURL:url error:&error];
        self.player = [[IDZAQAudioPlayer alloc] initWithDecoder:decoder error:&error];
        [self.player play];
        streamStarted = YES;
    }
    close(chapfd);
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
        return [self hideChapter:chapterTitle];
    }
    
    if([self.pathSegments count] > 1){
        [self.pathSegments removeLastObject];
    }
    [self.pathSegments addObject:chapterTitle];
    self.chapterTitle.text = chapterTitle;
    
    self.chapterTitle.font = [UIFont fontWithName:@"Hevetica Neue" size:16];
    float total_y_offset = CGRectGetHeight(self.chapterTitle.frame) + CGRectGetHeight(self.controls.frame);
    float title_y_offset = CGRectGetHeight(self.chapterTitle.frame);
    float control_y_offset = total_y_offset - title_y_offset ;
    NSLog(@"total: %f title %f control: %f", total_y_offset, title_y_offset, control_y_offset);
    self.chapterTitle.frame = CGRectMake(CGRectGetMinX(self.chapterCircleContainer.frame),
                                         CGRectGetMinY(self.chapterCircleContainer.frame) - title_y_offset ,
                                         CGRectGetWidth( self.chapterTitle.frame ),
                                         CGRectGetHeight( self.chapterTitle.frame));
    self.controls.frame = CGRectMake(
                                     CGRectGetMinX(self.chapterCircleContainer.frame),
                                     CGRectGetMinY(self.chapterCircleContainer.frame) - control_y_offset,
                                     CGRectGetWidth(self.controls.frame),
                                     CGRectGetHeight(self.controls.frame));
    [self.view addSubview:self.chapterTitle];
    [self.view addSubview:self.controls];
    self.chapterTitle.hidden = NO;
    self.controls.hidden = NO;
    [self.controls.playButton addTarget:self action:@selector(playChapter:) forControlEvents:UIControlEventTouchDown];
    [self.controls.pauseButton addTarget:self action:@selector(pauseChapter:) forControlEvents:UIControlEventTouchDown];
    [self.controls.streamButton addTarget:self action:@selector(streamChapter:) forControlEvents:UIControlEventTouchDown];
    [self.controls.cancelButton addTarget:self action:@selector(cancelStream:) forControlEvents:UIControlEventTouchDown];
    
    [UIView animateWithDuration:0.3 animations:^(void){
        self.chapterTitle.frame             = CGRectMake(CGRectGetMinX(self.chapterCircleContainer.frame),
                                                         CGRectGetMinY(self.chapterCircleContainer.frame)  ,
                                                         CGRectGetWidth( self.chapterTitle.frame ),
                                                         CGRectGetHeight( self.chapterTitle.frame));
        self.controls.frame                 = CGRectMake(
                                                         CGRectGetMinX(self.chapterCircleContainer.frame),
                                                         CGRectGetMinY(self.chapterCircleContainer.frame)
                                                            + control_y_offset,
                                                         CGRectGetWidth(self.chapterCircleContainer.frame),
                                                         CGRectGetHeight(self.controls.frame));
        self.chapterCircleContainer.frame   = CGRectMake(
                                                        CGRectGetMinX(self.chapterCircleContainer.frame),
                                                         CGRectGetMaxY(self.controls.frame),
                                                         CGRectGetWidth(self.chapterCircleContainer.frame),
                                                         CGRectGetHeight(self.chapterCircleContainer.frame));
        self.bookTitle.frame                = CGRectMake(
                                                         CGRectGetMinX(self.bookTitle.frame),
                                                         CGRectGetMaxY(self.chapterCircleContainer.frame),
                                                         CGRectGetWidth(self.bookTitle.frame),
                                                         CGRectGetHeight(self.bookTitle.frame));
        self.circleContainer.frame          = CGRectMake(
                                                         CGRectGetMinX(self.circleContainer.frame),
                                                         CGRectGetMaxY(self.bookTitle.frame),
                                                         CGRectGetWidth(self.circleContainer.frame),
                                                         CGRectGetHeight(self.circleContainer.frame)
        );
        
    }];
    chapterDisplayed = YES;
}

-(void) checkStatus {
    [radioClient checkTemperature:^(NSString *temperature) {
        self.controls.tempLabel.text = [NSString stringWithFormat:@"%@ °F", temperature];
    }];
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

-(IBAction) cancelStream:(id)sender {
    if(streamStarted){
        [self.player stop];
        streamStarted = NO;
    }
    [radioClient cancelCurrentStream];
    self.controls.streamButton.hidden = NO;
    self.controls.streamButton.userInteractionEnabled = YES;
    self.controls.cancelButton.hidden = YES;
    self.controls.cancelButton.userInteractionEnabled = NO;
    streamCancelled = YES;
}

-(IBAction) streamChapter:(id)sender {
    if (streamStarted) {
        [self.player stop];
        streamStarted = NO;
    }
    [radioClient streamTrack:[NSString pathWithComponents:self.pathSegments]];
    [self.statusTimer invalidate];
    self.statusTimer = [NSTimer timerWithTimeInterval:1.0F target:self selector:@selector(checkStatus) userInfo:nil repeats:YES];
    [self.statusTimer setTolerance:1.0F];
    [[NSRunLoop mainRunLoop] addTimer:self.statusTimer forMode:NSRunLoopCommonModes];
    self.controls.streamButton.hidden = YES;
    self.controls.streamButton.userInteractionEnabled = NO;
    self.controls.cancelButton.hidden = NO;
    self.controls.cancelButton.userInteractionEnabled = YES;
    streamCancelled = NO;
}

-(IBAction)resetView:(id)sender{
    chapterDisplayed = NO;
    [self repositionChapterCircleToInitialState];
    [self.bookTitle removeFromSuperview];
    [self.controls removeFromSuperview];
    self.controls.hidden = YES;
    [self.chapterTitle removeFromSuperview];
    self.chapterTitle.hidden = YES;
    [self hideBookTitle:nil];
    [self.view addGestureRecognizer:self.recognizer];
    [self.view removeGestureRecognizer:self.resetRecognizer];
    [self.statusTimer invalidate];
    
}

-(void) repositionChapterCircleToInitialState {
    [self.chapterCircleContainer removeFromSuperview];
    self.chapterTitle.frame = initialChapterTitleFrame;
    
}


     
@end
