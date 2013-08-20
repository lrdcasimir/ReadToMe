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

CDCircle* circleMenu;
RadioClient* radioClient;
BOOL bookTitleDisplayed = NO;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    radioClient = [[RadioClient alloc] init];
    radioClient.delegate = self;
    [radioClient discoverRadioLister];
    
    self.recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panning:)];

    
    self.circleContainer = [[UIView alloc] initWithFrame:CGRectMake(10, 40, 280, 280)];
    self.circleContainer.backgroundColor = [UIColor redColor];
    
    
    
    
    circleMenu = [[CDCircle alloc] initWithFrame:CGRectMake(0, 0, 280, 280) numberOfSegments:3 ringWidth:100];
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
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void) circle:(CDCircle *)circle didMoveToSegment:(NSInteger)segment thumb:(CDCircleThumb *)thumb
{
    switch (segment) {
        case 0:
            [self displayBookTitle:@"The Hobbit"];
            break;
        case 1:
            [self displayBookTitle:@"Einstein's Dreams"];
             break;
        case 2:
            [self displayBookTitle:@"The Notebook"];
            break;
       default:
            
            break;
    }
}

-(void) displayBookTitle:(NSString*)title{
    if (bookTitleDisplayed) {
        return [self hideBookTitle:title];
    }
    self.bookTitle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.circleContainer.frame), CGRectGetMinY(self.circleContainer.frame) -100, 280, 100)];
    self.bookTitle.text = title;
    self.bookTitle.font = [UIFont fontWithName:@"Helvetica Neue" size:26];
    
    [self.view insertSubview:self.bookTitle belowSubview:self.circleContainer];
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
        self.bookTitle.center = CGPointMake(self.bookTitle.center.x, self.bookTitle.center.y + 100);
        self.circleContainer.center = CGPointMake(self.circleContainer.center.x, self.circleContainer.center.y +100 );
    
    } completion:^(BOOL finished){
        [self.view addGestureRecognizer:self.recognizer];
    }];
    bookTitleDisplayed = YES;
}

-(void) hideBookTitle:(NSString*)nextTitle {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
        self.bookTitle.center = CGPointMake(self.bookTitle.center.x, self.bookTitle.center.y - 100);
        self.circleContainer.center = CGPointMake(self.circleContainer.center.x, self.circleContainer.center.y - 100);
    }completion:^(BOOL finished){
        bookTitleDisplayed = NO;
        [self.bookTitle removeFromSuperview];
        [self displayBookTitle:nextTitle];
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
}

-(IBAction)panning:(id)sender{
    
    
    float y = [self.recognizer translationInView:self.view].y;
    NSLog(@"panning %f", y);
    if(y>0 && y>180 && self.recognizer.state != UIGestureRecognizerStateEnded){
        self.bookTitle.center = CGPointMake(self.bookTitle.center.x,
                                            y+20);
        self.circleContainer.frame =
        CGRectMake(
                                CGRectGetMinX(self.circleContainer.frame),
                                CGRectGetMaxY(self.bookTitle.frame),
                                CGRectGetWidth(self.circleContainer.frame),
                                CGRectGetHeight(self.circleContainer.frame));
    }
    
    if(y>180 && self.recognizer.state == UIGestureRecognizerStateEnded){
        [self.view removeGestureRecognizer:self.recognizer];
        [UIView animateWithDuration:0.3 animations:^(void){
            self.bookTitle.center = CGPointMake(self.bookTitle.center.x,
                                                320);
            self.circleContainer.frame =
            CGRectMake(
                       CGRectGetMinX(self.circleContainer.frame),
                       CGRectGetMaxY(self.bookTitle.frame),
                       CGRectGetWidth(self.circleContainer.frame),
                       CGRectGetHeight(self.circleContainer.frame));
        }];
    }

    
}
     
@end
