//
//  PlayerControls.h
//  ReadToMe
//
//  Created by Vann-Campbell, Tyler on 11/21/13.
//  Copyright (c) 2013 Vann-Campbell, Tyler. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerControls : UIView
@property (nonatomic, strong) IBOutlet UILabel* tempLabel;
@property (nonatomic, strong) IBOutlet UILabel* bytesLabel;
@property (nonatomic, strong) IBOutlet UIButton* playButton;
@property (nonatomic, strong) IBOutlet UIButton* pauseButton;
@property (nonatomic, strong) IBOutlet UIButton* streamButton;
@property (nonatomic, strong) IBOutlet UIButton* cancelButton;
@end
