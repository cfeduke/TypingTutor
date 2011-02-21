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
	NSMutableDictionary *attributes;
	BOOL isBold;
	BOOL isItalic;
}

@property (retain, readwrite) NSColor *bgColor;
@property (copy, readwrite) NSString *string;
@property (readwrite) BOOL isBold;
@property (readwrite) BOOL isItalic;

-(void)drawStringCenteredIn:(NSRect)r;
-(void)prepareAttributes;
-(IBAction)savePDF:(id)sender;
-(IBAction)cut:(id)sender;
-(IBAction)copy:(id)sender;
-(IBAction)paste:(id)sender;

@end
