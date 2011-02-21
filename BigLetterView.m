//
//  BigLetterView.m
//  TypingTutor
//
//  Created by Charles Feduke on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BigLetterView.h"
#import "FirstLetter.h"

@interface BigLetterView()
-(void)writeToPasteboard:(NSPasteboard *)pb;
-(BOOL)readFromPasteboard:(NSPasteboard *)pb;
@end


@implementation BigLetterView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[self prepareAttributes];
        bgColor = [[NSColor yellowColor] retain];
		string = @"";
    }
    return self;
}

-(void)dealloc {
	[bgColor release];
	[string release];
	[attributes release];
	[super dealloc];
}

-(void)drawRect:(NSRect)rect {
	NSRect bounds = [self bounds];
	[bgColor set];
	[NSBezierPath fillRect:bounds];
	
	[self drawStringCenteredIn:bounds];
	
	if (([[self window] firstResponder] == self) && [NSGraphicsContext currentContextDrawingToScreen]) 
	{
		[NSGraphicsContext saveGraphicsState];
		NSSetFocusRingStyle(NSFocusRingOnly);
		[NSBezierPath fillRect:bounds];
		[NSGraphicsContext restoreGraphicsState];
	}
}

-(BOOL)isOpaque {
	return YES;
}

-(BOOL)acceptsFirstResponder {
	NSLog(@"Accepting");
	return YES;
}

-(BOOL)resignFirstResponder {
	NSLog(@"Resigning");
	[self setNeedsDisplay:YES];
	[self setKeyboardFocusRingNeedsDisplayInRect:[self bounds]];
	return YES;
}

-(BOOL)becomeFirstResponder {
	NSLog(@"Becoming");
	[self setNeedsDisplay:YES];
	return YES;
}

-(void)keyDown:(NSEvent*)event {
	[self interpretKeyEvents:[NSArray arrayWithObject:event]];
}

-(void)insertText:(NSString*)input {
	[self setString:input];
}

-(void)insertTab:(id)sender {
	[[self window] selectKeyViewFollowingView:self];
}

-(void)insertBacktab:(id)sender {
	[[self window] selectKeyViewPrecedingView:self];
}

-(void)deleteBackward:(id)sender {
	[self setString:@" "];
}

-(void)prepareAttributes {
	attributes = [[NSMutableDictionary alloc] init];
	NSFont *font = [NSFont fontWithName:@"Helvetica" size:75];
	NSFontManager *fm = [NSFontManager sharedFontManager];
	
	if (isBold) {
		font = [fm convertFont:font toHaveTrait:NSBoldFontMask];
	}
	
	if (isItalic) {
		font = [fm convertFont:font toHaveTrait:NSItalicFontMask];
	}
		
	[attributes setObject:font forKey:NSFontAttributeName];
	[attributes setObject:[NSColor redColor] forKey:NSForegroundColorAttributeName];
	NSShadow *shadow = [[NSShadow alloc] init];
	[shadow setShadowOffset:NSMakeSize(5, -5)];
	[shadow setShadowBlurRadius:10.0];
	[shadow setShadowColor:[NSColor shadowColor]];
	[attributes setObject:shadow forKey:NSShadowAttributeName];
	
}

-(void)drawStringCenteredIn:(NSRect)r {
	NSSize strSize = [string sizeWithAttributes:attributes];
	NSPoint strOrigin;
	strOrigin.x = r.origin.x + (r.size.width - strSize.width)/2;
	strOrigin.y = r.origin.y + (r.size.height - strSize.height)/2;
	[string drawAtPoint:strOrigin withAttributes:attributes];
}

-(IBAction)savePDF:(id)sender {
	NSSavePanel* panel = [NSSavePanel savePanel];
	[panel setRequiredFileType:@"pdf"];
	[panel beginSheetForDirectory:nil
							 file:nil
				   modalForWindow:[self window]
					modalDelegate:self 
				   didEndSelector:@selector(didEnd:returnCode:contextInfo:)
					  contextInfo:NULL];
}

-(void)didEnd:(NSSavePanel *)sheet returnCode:(int)code contextInfo:(void *)contextInfo {
	if (code != NSOKButton)
		return;
	
	NSRect r = [self bounds];
	NSData *data = [self dataWithPDFInsideRect:r];
	NSString *path = [sheet filename];
	NSError *error;
	BOOL successful = [data writeToFile:path
								options:0
								  error:&error];
	if (!successful)
	{
		NSAlert *a = [NSAlert alertWithError:error];
		[a runModal];
	}
}

-(IBAction)cut:(id)sender {
	[self copy:sender];
	[self setString:@""];
}

-(IBAction)copy:(id)sender {
	NSPasteboard *pb = [NSPasteboard generalPasteboard];
	[self writeToPasteboard:pb];
}

-(IBAction)paste:(id)sender {
	NSPasteboard *pb = [NSPasteboard generalPasteboard];
	if (![self readFromPasteboard:pb]) {
		NSBeep();
	}
}

-(void)writeToPasteboard:(NSPasteboard *)pb {
	[pb declareTypes:[NSArray arrayWithObjects:NSPDFPboardType,NSStringPboardType,nil] owner:self];
	NSData *data = [self dataWithPDFInsideRect:[self bounds]];
	[pb setData:data forType:NSPDFPboardType];
	[pb setString:string forType:NSStringPboardType];
}

-(BOOL)readFromPasteboard:(NSPasteboard *)pb {
	NSArray *types = [pb types];
	if ([types containsObject:NSStringPboardType]) {
		NSString *value = [pb stringForType:NSStringPboardType];
		[self setString:[value BNR_firstLetter]];
		return YES;
	}
	return NO;
}

#pragma mark Accessors

-(void)setBgColor:(NSColor *)c {
	[c retain];
	[bgColor release];
	bgColor = c;
	[self setNeedsDisplay:YES];
}

-(NSColor*)bgColor {
	return bgColor;
}

-(void)setString:(NSString*)c {
	c = [c copy];
	[string release];
	string = c;
	NSLog(@"The string is now %@", string);
	[self setNeedsDisplay:YES];
}

-(NSString*)string {
	return string;
}

-(void)setIsBold:(BOOL)b {
	isBold = b;
	[self prepareAttributes];
}

-(BOOL)isBold {
	return isBold;
}

-(void)setIsItalic:(BOOL)i {
	isItalic = i;
	[self prepareAttributes];
}

-(BOOL)isItalic {
	return isItalic;
}


@end
