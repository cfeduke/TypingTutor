//
//  TypingTutorAppDelegate.h
//  TypingTutor
//
//  Created by Charles Feduke on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class BigLetterView;

@interface TypingTutorAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	IBOutlet BigLetterView *bigLetterView;
}

@property (assign) IBOutlet NSWindow *window;

@end
