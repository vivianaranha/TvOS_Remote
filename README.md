#Apple TV Project (Receiver)

Step 1: Create a TvOS Project and import the files from RemoteReceiver
    libRemoteReceiver.a
    RemoteReceiver.h

Step 2: In your ViewController.m file import the RemoteReceiver.h file

    `#import "RemoteReceiver.h"`

Step 3: Inside ViewController.m file add the following code 

@interface ViewController () <RemoteReceiverDelegate>

@property (nonatomic, strong) RemoteReceiver *remoteReceiver;

@end

Step 4: Inside viewDidLoad alloc and set the delegate for remoteReceiver

self.remoteReceiver = [[RemoteReceiver alloc] init];
self.remoteReceiver.delegate = self;


Step 5: Implement the following delegate methods for messages send from iOS remote app

-(void) didReceiveUpSwipe{
NSLog(@"Swipe UP");
}

-(void) didReceiveDownSwipe{
NSLog(@"Swipe DOWN");
}

-(void) didReceiveRightSwipe{
NSLog(@"Swipe RIGHT");
}

-(void) didReceiveLeftSwipe{
NSLog(@"Swipe LEFT");
}

#iOS Project (Sender/Remote Control)

Step 1: Create an iOS Project and import the files from RemoteSender
libRemoteSender.a
RemoteSender.h

Step 2: Import the RemoteSender class in your ViewController
#import "RemoteSender.h"

Step 3: Update ViewController.m with the following code

@interface ViewController ()

@property(nonatomic, strong) RemoteSender *remoteSender;

@end

Step 4: Allocate and initialize the remoteSender object
self.remoteSender = [[RemoteSender alloc] init];

Step 5: Implement gestures and methods (Check below for just button code)

- (IBAction)up:(id)sender {
[self.remoteSender sendUpGesture];
}

- (IBAction)down:(id)sender {
[self.remoteSender sendDownGesture];
}

- (IBAction)right:(id)sender {
[self.remoteSender sendRightGesture];
}

- (IBAction)left:(id)sender {
[self.remoteSender sendLeftGesture];
}
