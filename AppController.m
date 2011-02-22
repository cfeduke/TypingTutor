//
//  AppController.m
//  TypingTutor
//
//  Created by Charles Feduke on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"
#import "BigLetterView.h"

#define MAX_COUNT (100)

@implementation AppController

-(id)init {
	[super init];
	
	letters = [[NSArray alloc] initWithObjects:@"a", @"s", @"d", @"f", @"j", @"k", @"l", @";", @"{", @"}", nil];
	srandom(time(NULL));
	stepSize = 5;
	return self;
}

-(void)awakeFromNib {
	[self showAnotherLetter];
}

-(void)resetCount {
	[self willChangeValueForKey:@"count"];
	count = 0;
	[self didChangeValueForKey:@"count"];
}

-(void)incrementCount {
	[self willChangeValueForKey:@"count"];
	count += stepSize;
	if (count > MAX_COUNT) {
		count = MAX_COUNT;
	}
	[self didChangeValueForKey:@"count"];
}

-(void)showAnotherLetter {
	int x = lastIndex;
	while (x == lastIndex) {
		x = random() % [letters count];
	}
	
	lastIndex = x;
	[outLetterView setString:[letters objectAtIndex:x]];
	
	[self resetCount];
}

-(IBAction)stopGo:(id)sender {
	if (timer == nil) {
		NSLog(@"Starting");
		
		timer = [[NSTimer scheduledTimerWithTimeInterval:0.1
												  target:self
												selector:@selector(checkThem:)
												userInfo:nil
												 repeats:YES] retain];
	} else {
		NSLog(@"Stopping");
		
		[timer invalidate];
		[timer release];
		timer = nil;
	}
}

-(void)checkThem:(NSTimer *)aTimer {
	if ([[inLetterView string] isEqual:[outLetterView string]]) {
		[self showAnotherLetter];
	}
	if (count == MAX_COUNT) {
		NSBeep();
		[self resetCount];
	} else {
		[self incrementCount];
	}
}

-(IBAction)showSpeedSheet:(id)sender {
	[NSApp beginSheet:speedSheet
	   modalForWindow:[inLetterView window]
		modalDelegate:nil
	   didEndSelector:NULL
		  contextInfo:NULL];
}

-(IBAction)endSpeedSheet:(id)sender {
	[NSApp endSheet:speedSheet];
	[speedSheet orderOut:sender];
}
@end
