//
//  AppController.h
//  TypingTutor
//
//  Created by Charles Feduke on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class BigLetterView;

@interface AppController : NSObject {
	IBOutlet BigLetterView *inLetterView;
	IBOutlet BigLetterView *outLetterView;
	IBOutlet NSWindow *speedSheet;
	
	NSArray *letters;
	int lastIndex;
	
	NSTimer *timer;
	int count;
	
	int stepSize;
}

-(IBAction)stopGo:(id)sender;
-(IBAction)showSpeedSheet:(id)sender;
-(IBAction)endSpeedSheet:(id)sender;
-(void)incrementCount;
-(void)resetCount;
-(void)showAnotherLetter;

@end
