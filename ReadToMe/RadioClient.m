//
//  RadioClient.m
//  ReadToMe
//
//  Created by Vann-Campbell, Tyler on 8/18/13.
//  Copyright (c) 2013 Vann-Campbell, Tyler. All rights reserved.
//

#import "RadioClient.h"
#import "AFNetworking.h"

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
    NSURL* url = [NSURL URLWithString: [NSString stringWithFormat:@"http://%@:%d/?udid=%@", self.readToMeService.hostName, (int)self.readToMeService.port, [device.identifierForVendor UUIDString]]];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    NSURLConnection* connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
}

-(void) requestTrack:(NSString *)path{
    NSURL* url  = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%ld/play?chapterPath=%@",
                                         self.hostname, (long)portNumber,
                                         [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    NSLog(@"%@", url);
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    self.stopPlayConnection  = [NSURLConnection connectionWithRequest:request delegate:self];
    [self.stopPlayConnection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
}

-(void) cancelCurrentStream{
    [self.streamOp cancel];
}

-(void) streamTrack:(NSString *)path{
    [self cancelCurrentStream];
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%ld/stream?chapterPath=books/%@",
                   self.hostname, (long)portNumber,
                   [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    NSURLRequest* streamRequest = [NSURLRequest requestWithURL:url];
    self.streamOp = [[AFHTTPRequestOperation alloc] initWithRequest:streamRequest];
    NSString* tempPath  = [NSString pathWithComponents:@[NSTemporaryDirectory(),@"currentchapter.ogg"]];
    int tempfd = open([tempPath cStringUsingEncoding:NSUTF8StringEncoding], O_TRUNC);
    ftruncate(tempfd, 0);
    close(tempfd);
    NSOutputStream* stream = [NSOutputStream outputStreamToFileAtPath:tempPath append:NO];
    [stream open];
    self.streamOp.outputStream = stream;
    __weak RadioClient* rdc = self;
    
    [self.streamOp setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpected){
        [rdc.delegate radioRespondedWithStream:tempPath bytesRead:bytesRead];
    }];
    
    [[NSOperationQueue mainQueue] addOperation:self.streamOp];
}

-(void) checkTemperature:(void (^)(NSString *))done {
    NSString* path = [NSString stringWithFormat:@"http:/%@:%ld/temp",self.hostname, (long)portNumber];
    AFHTTPRequestOperationManager* mgr = [AFHTTPRequestOperationManager manager];
    mgr.responseSerializer = [AFJSONResponseSerializer serializer];
    [mgr GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* dict = (NSDictionary*) responseObject;
        done([dict objectForKey:@"temp"]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        done(@"--");
    }];
}

-(void) pause {
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%ld/pause", self.hostname,(long)portNumber]];
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
    [delegate radioDiscovered:[NSString stringWithFormat:@"%@:%ld", sender.hostName, (long)sender.port]];
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
