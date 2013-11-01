//
//  ChapterController.h
//  ReadToMe
//
//  Created by Vann-Campbell, Tyler on 10/11/13.
//  Copyright (c) 2013 Vann-Campbell, Tyler. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ChapterController <NSObject>

@required -(void) displayChapter:(NSString*)chapterTitle;

@end
