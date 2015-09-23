//
//  ViewController.m
//  TheRemote
//
//  Created by Vivian Aranha on 9/22/15.
//  Copyright © 2015 Vivian Aranha. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property(nonatomic, strong) RemoteSender *remoteSender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.remoteSender = [[RemoteSender alloc] init];
}


- (IBAction)sendSomeInformation:(id)sender {
    
    NSDictionary *theDictionaryToSendToTV = @{@"name": @"John Smith",@"age": @"35", @"address":@"123 Main St"};
    
    [self.remoteSender sendInfo:theDictionaryToSendToTV];
    
}

@end
