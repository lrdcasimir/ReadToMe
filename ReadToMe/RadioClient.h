//
//  RadioClient.h
//  ReadToMe
//
//  Created by Vann-Campbell, Tyler on 8/18/13.
//  Copyright (c) 2013 Vann-Campbell, Tyler. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RadioClientDelegate <NSObject>

-(void) radioDiscovered:(NSString*)host;
-(void) radioRespondedWithJson:(NSString*)response;


@end

@interface RadioClient : NSObject <NSNetServiceBrowserDelegate,NSNetServiceDelegate,NSURLConnectionDataDelegate>

@property (atomic, retain) id <RadioClientDelegate>  delegate;
@property (atomic, strong) NSNetService* readToMeService;
@property (strong, atomic) NSMutableData* rawServiceData;
-(void) discoverRadioLister;

-(void) getListFromRadio;

-(void) requestTrack:(NSString*)path;

@end
