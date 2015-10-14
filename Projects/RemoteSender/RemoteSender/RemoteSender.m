//
//  RemoteSender.m
//  RemoteSender
//
//  Created by Vivian Aranha on 9/22/15.
//  Copyright © 2015 Vivian Aranha. All rights reserved.
//

#import "RemoteSender.h"
#import "GCDAsyncSocket.h"

#define SERVICE_NAME @"_probonjore._tcp."
#define ACK_SERVICE_NAME @"_ack._tcp."


@interface RemoteSender () <NSNetServiceBrowserDelegate,NSNetServiceDelegate,GCDAsyncSocketDelegate>


@property(nonatomic,strong) NSNetServiceBrowser* coServiceBrowser;
@property(nonatomic, strong) NSMutableData* mutableData;
@property(nonatomic,strong) NSMutableDictionary* dictSockets;
@property(nonatomic,strong) NSNetService * service;
@property(nonatomic,strong) GCDAsyncSocket* socket;
@property(strong) NSMutableArray* arrDevices;
@property(nonatomic, assign) BOOL isConnected;

@end

@implementation RemoteSender

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isConnected = NO;
        self.dictSockets=[NSMutableDictionary dictionary];
        [self startService];
    }
    return self;
}

-(void)startService{
    if (self.arrDevices) {
        [self.arrDevices removeAllObjects];
        
    }else{
        self.arrDevices=[NSMutableArray array];
    }
    
    self.coServiceBrowser=[[NSNetServiceBrowser alloc]init];
    self.coServiceBrowser.delegate=self;
    [self.coServiceBrowser searchForServicesOfType:SERVICE_NAME inDomain:@"local."];
    
}

#pragma mark - Service Delegate


-(void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict{
    
    [sender setDelegate:self];
}

-(void)netServiceDidResolveAddress:(NSNetService *)sender{
    if ([self connectWithServer:sender]) {
    }
}


-(BOOL)connectWithServer:(NSNetService*)service{
    BOOL isConnected = NO;
    
    NSArray* arrAddress =[[service addresses] mutableCopy];
    GCDAsyncSocket * coSocket= [self.dictSockets objectForKey:service.name];
    
    
    if (!coSocket  || ![coSocket isConnected]) {
        GCDAsyncSocket * coSocket=[[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        //Connect
        while (!isConnected && [arrAddress count]) {
            NSData* address= [arrAddress objectAtIndex:0];
            NSError* error;
            if ([coSocket connectToAddress:address error:&error]) {
                [self.dictSockets setObject:coSocket forKey:service.name];
                isConnected=YES;
            }else if(error){
            }
        }
    }else{
        isConnected = [coSocket isConnected];
    }
    
    
    return isConnected;
}


#pragma mark GCDAsyncSocket delegate
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    [sock readDataToLength:sizeof(uint64_t) withTimeout:-1.0 tag:0];
    
    
}


-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    
}


-(GCDAsyncSocket*)getSelectedSocket{
    NSNetService* coService =[self.arrDevices objectAtIndex:0];
    return  [self.dictSockets objectForKey:coService.name];
    
}

-(void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
    
    [sock readDataWithTimeout:-1.0f tag:0];
    
    
}


-(void)socketDidCloseReadStream:(GCDAsyncSocket *)sock{
    
    
}
#pragma mark- Service browser delegate;

-(void)stopBrowsing{
    if (self.coServiceBrowser) {
        [self.coServiceBrowser stop];
        self.coServiceBrowser.delegate=nil;
        [self setCoServiceBrowser:nil];
    }
}

-(void) netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)aNetServiceBrowser{
    [self stopBrowsing];
}
-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didNotSearch:(NSDictionary *)errorDict{
    [self stopBrowsing];
}


-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing{
    if (aNetService) {
        
        [self.arrDevices removeObject:aNetService];
    }
    
    
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing{
    if (aNetService) {
        [self.arrDevices addObject:aNetService];
        
//        NSLog(@"Selected Device %@", aNetService.name);
        aNetService.delegate=self;
        [aNetService resolveWithTimeout:30.0f];
    }
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(sendSomeFakePings:) userInfo:nil repeats:YES];
    
}

int count = 0;

-(void) sendSomeFakePings:(NSTimer *) timer {
    count++;
    NSData* data=[@"TEST" dataUsingEncoding:NSUTF8StringEncoding];
    [[self getSelectedSocket] writeData:data withTimeout:-1.0f tag:0];
    if(count > 5){
        [timer invalidate];
    }
}

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser {
//    NSLog(@"Will Search");
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindDomain:(NSString *)domainString moreComing:(BOOL)moreComing {
//    NSLog(@"Found");
}


-(void) sendInfo:(NSDictionary *) infoDict {
    NSData *dictData = [NSKeyedArchiver archivedDataWithRootObject:infoDict];
    [[self getSelectedSocket] writeData:dictData withTimeout:-1.0f tag:0];

}

@end
