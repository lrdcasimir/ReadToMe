//
//  RadioClient.m
//  ReadToMe
//
//  Created by Vann-Campbell, Tyler on 8/18/13.
//  Copyright (c) 2013 Vann-Campbell, Tyler. All rights reserved.
//

#import "RadioClient.h"

@implementation RadioClient

id <RadioClientDelegate> delegate;
NSNetServiceBrowser* serviceBrowser;

@synthesize delegate;

-(id) init {
    self = [super init];
    serviceBrowser = [[NSNetServiceBrowser alloc] init];
    serviceBrowser.delegate = self;
    return self;
}

-(void) discoverRadioLister {
    [serviceBrowser scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [serviceBrowser searchForServicesOfType:@"_readToMe._tcp" inDomain:@""];
}

-(void) getListFromRadio {
    NSURL* url = [NSURL URLWithString: [NSString stringWithFormat:@"http://%@:%d", self.readToMeService.hostName, self.readToMeService.port]];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    NSURLConnection* connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
}

-(void) requestTrack:(NSString *)path{
    
}

-(void) netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didNotSearch:(NSDictionary *)errorDict{
    NSLog(@"didn't search %@", errorDict);
}

-(void) netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    self.readToMeService = aNetService;
    self.readToMeService.delegate = self;
    
    
    if(!moreComing){
        [serviceBrowser stop];
        [self.readToMeService resolveWithTimeout:5000];
    }
}

-(void) netServiceDidResolveAddress:(NSNetService *)sender{
    self.readToMeService = sender;
    [delegate radioDiscovered:[NSString stringWithFormat:@"%@:%d", sender.hostName, sender.port]];
}

-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    self.rawServiceData = [[NSMutableData alloc] initWithCapacity:response.expectedContentLength];
    
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.rawServiceData appendBytes:data.bytes length:data.length];
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString* jsonResponse = [NSString stringWithUTF8String:self.rawServiceData.bytes];
    [delegate radioRespondedWithJson:jsonResponse];
}



@end
