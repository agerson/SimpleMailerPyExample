//
//  SimpleMailerPyExampleAppDelegate.h
//  SimpleMailerPyExample
//
//  Created by Adam Gerson on 2/26/11.
//  Copyright 2011 Adam Gerson. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SimpleMailerPyExampleAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	IBOutlet NSTextField *resultTextField;
}

@property (assign) IBOutlet NSWindow *window;

- (IBAction)sendEmail:(id)sender;

@end
