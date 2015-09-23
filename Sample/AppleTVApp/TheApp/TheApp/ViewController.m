//
//  ViewController.m
//  TheApp
//
//  Created by Vivian Aranha on 9/22/15.
//  Copyright © 2015 Vivian Aranha. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <RemoteReceiverDelegate>

@property (nonatomic, strong) RemoteReceiver *remoteReceiver;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.remoteReceiver = [[RemoteReceiver alloc] init];
    self.remoteReceiver.delegate = self;
    
}

-(void) didReceiveMessage:(NSDictionary *)userInfo{
    NSLog(@"%@",userInfo);
}



@end
