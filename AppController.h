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
	
	NSArray *letters;
	int lastIndex;
	
	NSTimer *timer;
	int count;
}

-(IBAction)stopGo:(id)sender;
-(void)incrementCount;
-(void)resetCount;
-(void)showAnotherLetter;

@end
