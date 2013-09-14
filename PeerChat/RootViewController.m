//
//  ViewController.m
//  PeerCommunication
//
//  Created by Patrick Jayet on 15/08/13.
//  Copyright (c) 2013 Patrick Jayet. All rights reserved.
//

#import "RootViewController.h"


static NSString* serviceType = @"zuehlke-chat";


@interface RootViewController ()

@property (readwrite) BOOL browserShown;

- (void) appendToMessageBoard:(NSString*)msg;

@end


@implementation RootViewController

#pragma mark custom methods

- (void) appendToMessageBoard:(NSString*)msg
{
    NSString* currentText = self.messageBoard.text;
    NSString* newText = [NSString stringWithFormat:@"%@\n%@", currentText, msg];
    self.messageBoard.text = newText;
    
    [self.messageBoard scrollRangeToVisible:NSMakeRange(newText.length-1, 1)];
}

- (IBAction)sendMessage:(id)sender
{
    NSString* msg = self.inputField.text;
    self.inputField.text = @"";
    
    NSString* line = [NSString stringWithFormat:@"%@> %@", self.peerId.displayName, msg];
    [self performSelectorOnMainThread:@selector(appendToMessageBoard:) withObject:line waitUntilDone:NO];
    
    NSData* data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError* error = nil;
    [self.session sendData:data toPeers:self.session.connectedPeers withMode:MCSessionSendDataReliable error:&error];
    
    if (error != nil) {
        [self appendToMessageBoard:@"Error occured when sending the previous message."];
    }
}

- (IBAction)startSession:(id)sender
{
    MCBrowserViewController* controller = [[MCBrowserViewController alloc] initWithServiceType:serviceType session:self.session];
    controller.delegate = self;
    [self presentViewController:controller animated:YES completion:nil];
    self.browserShown = YES;
}

#pragma mark method from UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark methods from MCSessionDelegate

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSString* msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSString* line = [NSString stringWithFormat:@"%@> %@", peerID.displayName, msg];
    [self performSelectorOnMainThread:@selector(appendToMessageBoard:) withObject:line waitUntilDone:NO];
    
    NSLog(@"did receive data from %@", peerID.displayName);
    
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
}

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    NSString* stateString = nil;
    if (state == MCSessionStateConnected) {
        stateString = @"connected";
    }
    else if (state == MCSessionStateNotConnected) {
        stateString = @"disconnected";
    }
    else if (state == MCSessionStateConnecting) {
        stateString = @"connecting";
    }
    
    NSString* statusMsg = [NSString stringWithFormat:@"%@ %@.", peerID.displayName, stateString];
    [self performSelectorOnMainThread:@selector(appendToMessageBoard:) withObject:statusMsg waitUntilDone:NO];
}

// only implement this method if we want to check the certificate
//- (void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL accept))certificateHandler
//{
//}

#pragma mark methods from MCBrowserViewControllerDelegate

- (BOOL)browserViewController:(MCBrowserViewController *)picker shouldPresentNearbyPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    return YES;
}

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    NSLog(@"Browser did finish");
    
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
    self.browserShown = NO;
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)picker
{
    NSLog(@"Browser was canceled");
    
    [self dismissViewControllerAnimated:YES completion:nil];
    self.browserShown = NO;
}

#pragma mark methods from UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSString* name = [[UIDevice currentDevice] name];
    self.peerId = [[MCPeerID alloc] initWithDisplayName:name];
    self.session = [[MCSession alloc] initWithPeer:self.peerId];
    self.session.delegate = self;
    
    self.assistant = [[MCAdvertiserAssistant alloc] initWithServiceType:serviceType discoveryInfo:nil session:self.session];
    [self.assistant start];
    
    [self appendToMessageBoard:[NSString stringWithFormat:@"Welcome to the chat '%@'!", self.peerId.displayName]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
