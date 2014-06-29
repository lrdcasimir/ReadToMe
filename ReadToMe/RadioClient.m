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
NSInteger portNumber;


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
    UIDevice* device = [UIDevice currentDevice];
    NSURL* url = [NSURL URLWithString: [NSString stringWithFormat:@"http://%@:%d/?udid=%@", self.readToMeService.hostName, self.readToMeService.port, [device.identifierForVendor UUIDString]]];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    NSURLConnection* connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
}

-(void) requestTrack:(NSString *)path{
    NSURL* url  = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%d/play?chapterPath=%@",
                                         self.hostname, portNumber,
                                         [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    NSLog(@"%@", url);
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    self.stopPlayConnection  = [NSURLConnection connectionWithRequest:request delegate:self];
    [self.stopPlayConnection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
}

-(void) pause {
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%d/pause", self.hostname,portNumber]];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    self.stopPlayConnection = [NSURLConnection connectionWithRequest:request delegate:self];
    [self.stopPlayConnection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

-(void) netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didNotSearch:(NSDictionary *)errorDict{
    NSLog(@"didn't search %@", errorDict);
}

-(void) netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    self.readToMeService = aNetService;
    self.readToMeService.delegate = self;
    if(!moreComing){
        [self.readToMeService resolveWithTimeout:5000];
    }
    
}

-(void) netServiceDidResolveAddress:(NSNetService *)sender{
    self.readToMeService = sender;
    [delegate radioDiscovered:[NSString stringWithFormat:@"%@:%d", sender.hostName, sender.port]];
    self.hostname = sender.hostName;
    portNumber = sender.port;
}

-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    if(connection == self.stopPlayConnection){
        return;
    }
    if(self.rawServiceData == nil){
        self.rawServiceData = [[NSMutableData alloc] initWithCapacity:response.expectedContentLength];
    }

}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    if(data == nil || connection == self.stopPlayConnection){
        return;
    }
    
    if(self.rawServiceData != nil){
        [self.rawServiceData appendBytes:data.bytes length:data.length];
    } else if(data != nil) {
        self.rawServiceData = [NSMutableData dataWithData:data];
    }
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection{
    if(connection == self.stopPlayConnection){
        NSLog(@"play request finished");
        [self.stopPlayConnection unscheduleFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    if(self.rawServiceData != nil){
        NSString* jsonResponse = [NSString stringWithUTF8String:self.rawServiceData.bytes];
        self.rawServiceData = nil;
        [delegate radioRespondedWithJson:jsonResponse];
    }
    
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"connection failed: %@", error);
}


@end
