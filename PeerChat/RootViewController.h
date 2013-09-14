//
//  ViewController.h
//  PeerCommunication
//
//  Created by Patrick Jayet on 15/08/13.
//  Copyright (c) 2013 Patrick Jayet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>


@interface RootViewController : UIViewController <MCSessionDelegate, MCBrowserViewControllerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) MCPeerID *peerId;
@property (strong, nonatomic) MCSession *session;
@property (strong, nonatomic) MCAdvertiserAssistant *assistant;

@property (strong, nonatomic) IBOutlet UITextView* messageBoard;
@property (strong, nonatomic) IBOutlet UITextField* inputField;

@end
