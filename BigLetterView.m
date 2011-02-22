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
		
		[self registerForDraggedTypes:[NSArray arrayWithObject:NSStringPboardType]];
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
	
	if (isHighlighted) {
		NSGradient *gr;
		gr = [[NSGradient alloc] initWithStartingColor:[NSColor whiteColor] endingColor:bgColor];
		[gr drawInRect:bounds relativeCenterPosition:NSZeroPoint];
		[gr release];
	}
	else
	{
		[bgColor set];
		[NSBezierPath fillRect:bounds];
	}
	
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

#pragma mark Drag and Drop

-(NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal {
	return NSDragOperationCopy | NSDragOperationDelete;
}

-(void)mouseDown:(NSEvent *)event {
	[event retain];
	[mouseDownEvent release];
	mouseDownEvent = event;
}

-(void)mouseDragged:(NSEvent *)event {
	NSPoint down = [mouseDownEvent locationInWindow];
	NSPoint drag = [event locationInWindow];
	float distance = hypot(down.x - drag.x, down.y - drag.y);
	if (distance < 3) {
		return;
	}
	
	if ([string length] == 0) {
		return;
	}
	
	NSLog(@"mouseDragged:");
	
	NSSize s = [string sizeWithAttributes:attributes];
	NSImage *anImage = [[NSImage alloc] initWithSize:s];
	NSRect imageBounds = NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, s.width, s.height);
	
	[anImage lockFocus];
	[self drawStringCenteredIn:imageBounds];
	[anImage unlockFocus];
	
	NSPoint p = [self convertPoint:down fromView:nil];
	
	p.x = p.x - s.width/2;
	p.y = p.y - s.height/2;
	
	NSPasteboard *pb = [NSPasteboard pasteboardWithName:NSDragPboard];
	
	[self writeToPasteboard:pb];
	
	[self dragImage:anImage at:p offset:s event:mouseDownEvent pasteboard:pb source:self slideBack:YES];
	
	[anImage release];
}

-(void)draggedImage:(NSImage *)image endedAt:(NSPoint)screenPoint operation:(NSDragOperation)operation {
	if (operation == NSDragOperationDelete) {
		[self setString:@""];
	}
}

#pragma mark Dragging Destination

-(NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
	NSLog(@"draggingEntered:");
	if ([sender draggingSource] == self) {
		return NSDragOperationNone;
	}
	
	isHighlighted = YES;
	[self setNeedsDisplay:YES];
	return NSDragOperationCopy;
}

-(void)draggingExited:(id <NSDraggingInfo>)sender {
	NSLog(@"draggingExited:");
	isHighlighted = NO;
	[self setNeedsDisplay:YES];
}

-(BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender {
	return YES;
}

-(BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
	NSPasteboard *pb = [sender draggingPasteboard];
	if (![self readFromPasteboard:pb]) {
		NSLog(@"Error: could not read from dragging pasteboard.");
		return NO;
	}
	
	isHighlighted = NO;
	[self setNeedsDisplay:YES];
	return YES;
}

-(NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender {
	NSDragOperation op = [sender draggingSourceOperationMask];
	NSLog(@"operation mask = %d", op);
	if ([sender draggingSource] == self) {
		return NSDragOperationNone;
	}
	return NSDragOperationCopy;
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
