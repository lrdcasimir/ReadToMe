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

CDCircle *circleMenu;
RadioClient *radioClient;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    radioClient = [[RadioClient alloc] init];
    radioClient.delegate = self;
    [radioClient discoverRadioLister];
    
    circleMenu = [[CDCircle alloc] initWithFrame:CGRectMake(20, 40, 280, 280) numberOfSegments:5 ringWidth:100];
    circleMenu.delegate = self;
    circleMenu.dataSource = self;
    CDCircleOverlayView *overlay = [[CDCircleOverlayView alloc] initWithCircle:circleMenu];
    circleMenu.circleColor = [UIColor colorWithRed:.8 green:0.85 blue:1 alpha:1];
    [self.view addSubview:circleMenu];
    [self.view addSubview:overlay];
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
}

@end
