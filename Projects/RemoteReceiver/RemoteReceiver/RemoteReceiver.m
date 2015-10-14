//
//  RemoteReceiver.m
//  RemoteReceiver
//
//  Created by Vivian Aranha on 9/22/15.
//  Copyright © 2015 Vivian Aranha. All rights reserved.
//

#import "RemoteReceiver.h"
#import "GCDAsyncSocket.h"

#define SERVICE_NAME @"_probonjore._tcp."
#define ACK_SERVICE_NAME @"_ack._tcp."

@interface RemoteReceiver() <GCDAsyncSocketDelegate, NSNetServiceDelegate, NSNetServiceBrowserDelegate>

@property(nonatomic, strong) NSMutableArray* arrServices;
@property(nonatomic,strong) NSNetServiceBrowser* coServiceBrowser;
@property(nonatomic,strong) NSMutableDictionary* dictSockets;
@property (strong, nonatomic) NSNetService *service;
@property (strong, nonatomic) GCDAsyncSocket *socket;

@end

@implementation RemoteReceiver

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self startBroadCasting];
    }
    return self;
}

-(void)startBroadCasting{
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError* error = nil;
    if ([self.socket acceptOnPort:0 error:&error]) {
        self.service =[[NSNetService alloc]initWithDomain:@"local." type:SERVICE_NAME name:@"" port:[self.socket localPort]];
        self.service.delegate=self;
        [self.service publish];
    }else {
//        NSLog(@"Unable to create socket. Error %@ with user info %@.", error, [error userInfo]);
    }
}

- (void)netServiceDidPublish:(NSNetService *)service {
//    NSLog(@"Bonjour Service Published: domain(%@) type(%@) name(%@) port(%i)", [service domain], [service type], [service name], (int)[service port]);
}
- (void)netService:(NSNetService *)service didNotPublish:(NSDictionary *)errorDict {
//    NSLog(@"Failed to Publish Service: domain(%@) type(%@) name(%@) - %@", [service domain], [service type], [service name], errorDict);
}


-(void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket{
    self.socket= newSocket;
    
    [self.socket readDataToLength:sizeof(uint64_t) withTimeout:-1.0f tag:0];
//    NSLog(@"Accepted the new socked");
    
    NSData* data= [@"Connected" dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket writeData:data withTimeout:-1.0f tag:0];
    
}


- (void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(NSError *)error {
    
//    NSLog(@"ERROR: %@", error.description);
    
    if (self.socket == socket) {
        [self startBroadCasting];
    }
}

-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
//    NSLog(@"Write data is done");
}


-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
    NSString *theTestString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if(!theTestString){
        NSDictionary *myDictionary = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [self.delegate didReceiveMessage:myDictionary];
    }
    [sock readDataWithTimeout:-1.0f tag:0];
}

-(GCDAsyncSocket*)getSelectedSocket{
    NSNetService* coService =[self.arrServices objectAtIndex:0];
    return  [self.dictSockets objectForKey:coService.name];
    
}



@end
