//
//  SimpleMailerPyExampleAppDelegate.m
//  SimpleMailerPyExample
//
//  Created by Adam Gerson on 2/26/11.
//
//  Code adapted from:
//	http://code.google.com/p/growl/source/browse/Plugins/Displays/MailMe/GrowlMailMeDisplay.m
//  
//  Copyright (c) The Growl Project, 2004-2010
//  All rights reserved.
//  
//  Redistribution and use in source and binary forms, with or without modification, 
//  are permitted provided that the following conditions are met:
//  
//  1. Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//  3. Neither the name of Growl nor the names of its contributors
//  may be used to endorse or promote products derived from this software
//  without specific prior written permission.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
//  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
//  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS 
//  OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY 
//  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
//  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
////


#import "SimpleMailerPyExampleAppDelegate.h"

@implementation SimpleMailerPyExampleAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	//[self sendEmail];
}

- (IBAction)sendEmail:(id)sender
{
	BOOL success = NO;
	
	NSString *username		= @"username";
	NSString *fromAddress	= @"username@host.com";
	NSString *destAddress	= @"someone@host.com";
	NSString *hostname		= @"smtp.host.com";
	NSString *subject		= @"Hello";
	NSString *password		= @"****";
	NSString *body			= @"This is the email body";
	NSString *userAgentName	= @"SimpleMailerPyExample";
	BOOL useTLS				= YES;
	NSNumber *port			= [NSNumber numberWithInt:587];
	
	NSString *result = @"";
	NSData *passwordData = [password dataUsingEncoding:NSASCIIStringEncoding];
	NSString *userAtHostPort = [NSString stringWithFormat:(port != nil) ? @"%@@%@:%@" : @"%@@%@", username, hostname, port];
	NSString *pathToMailSenderProgram = [[[NSBundle bundleForClass:[self class]] pathForResource:@"simple-mailer" ofType:@"py"] copy];
	NSString *userAgentFull = [@"--user-agent=" stringByAppendingFormat:@"%@/%@", userAgentName, [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey]];
	
	//Use only stock Python and matching modules.
	NSDictionary *environment = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"PYTHONPATH",@"/bin:/usr/bin:/usr/local/bin", @"PATH",nil];
	NSTask *task = [[[NSTask alloc] init] autorelease];
	[task setEnvironment:environment];
	[task setLaunchPath:@"/usr/bin/python"];
	
	[task setArguments:[NSArray arrayWithObjects:
						pathToMailSenderProgram,
						userAgentFull,
						useTLS ? @"--tls" : @"--no-tls",
						userAtHostPort,
						fromAddress,
						destAddress,
						subject,
						nil]];
	
	NSPipe *stdinPipe = [NSPipe pipe];
	[task setStandardInput:stdinPipe];
	[task launch];
	[[stdinPipe fileHandleForReading] closeFile];
	NSFileHandle *stdinFH = [stdinPipe fileHandleForWriting];
	[stdinFH writeData:passwordData];
	[stdinFH writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[stdinFH writeData:[[NSString stringWithFormat:@"%@", body] dataUsingEncoding:NSUTF8StringEncoding]];
	[stdinFH closeFile];
	[task waitUntilExit];
	success = ([task terminationStatus] == 0);
	
	if (!success) {
		result = [result stringByAppendingFormat:@"WARNING: Could not send email message \"%@\" to address %@", subject, destAddress];
	} else {
		result = [result stringByAppendingFormat:@"Successfully sent message \"%@\" to address %@", subject, destAddress];
	}
	[resultTextField setStringValue:result];
}

@end
