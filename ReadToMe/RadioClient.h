//
//  RadioClient.h
//  ReadToMe
//
//  Created by Vann-Campbell, Tyler on 8/18/13.
//  Copyright (c) 2013 Vann-Campbell, Tyler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFHTTPRequestOperation.h>

@protocol RadioClientDelegate <NSObject>

-(void) radioDiscovered:(NSString*)host;
-(void) radioRespondedWithJson:(NSString*)response;
-(void) radioRespondedWithStream:(NSString*)outputFile bytesRead:(NSUInteger)bytesRead;


@end

@interface RadioClient : NSObject <NSNetServiceBrowserDelegate,NSNetServiceDelegate,NSURLConnectionDataDelegate>

@property (atomic, weak) id <RadioClientDelegate>  delegate;
@property (atomic, strong) NSNetService* readToMeService;
@property (strong, atomic) NSMutableData* rawServiceData;
@property (strong, atomic) NSString* hostname;
@property (strong, atomic) NSURLConnection* stopPlayConnection;
@property (strong, nonatomic) AFHTTPRequestOperation* streamOp;

-(void) discoverRadioLister;

-(void) getListFromRadio;

-(void) requestTrack:(NSString*)path;

-(void) streamTrack:(NSString*)path;

-(void) cancelCurrentStream;

-(void) checkTemperature:(void (^)(NSString* temperature))done;

-(void) pause;

@end
