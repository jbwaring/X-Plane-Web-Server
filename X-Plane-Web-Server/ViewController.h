//
//  ViewController.h
//  X-Plane-Web-Server
//
//  Created by Jean-Baptiste Waring on 2022-01-20.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController
@property (weak) IBOutlet NSTextField *serverStatusTextField;
@property (weak) IBOutlet NSTextField *xplaneStatusTextField;
@property (weak) IBOutlet NSButton *connectToXPlaneButton;


@end

