//
//  BigLetterView.h
//  TypingTutor
//
//  Created by Charles Feduke on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BigLetterView : NSView {
	NSColor *bgColor;
	NSString *string;
}

@property (retain, readwrite) NSColor *bgColor;
@property (copy, readwrite) NSString *string;

@end
