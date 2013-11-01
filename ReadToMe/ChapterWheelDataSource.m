//
//  ChapterWheelDataSource.m
//  ReadToMe
//
//  Created by Vann-Campbell, Tyler on 10/8/13.
//  Copyright (c) 2013 Vann-Campbell, Tyler. All rights reserved.
//

#import "ChapterWheelDataSource.h"

@implementation ChapterWheelDataSource


-(void) circle:circle didMoveToSegment:(NSInteger)segment thumb:(CDCircleThumb *)thumb {
    if(segment < [[self.chapters allKeys] count]){
        NSString* chapterTitle = [[self.chapters allKeys] objectAtIndex:segment];
        NSLog(@"title %@", chapterTitle);
        [self.controller displayChapter:chapterTitle];
    }
}


-(UIImage*) circle:circle iconForThumbAtRow:(NSInteger)row {
    return [self.parentDataSource circle:circle iconForThumbAtRow:row];
};

@end
