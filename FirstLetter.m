//
//  FirstLetter.m
//  TypingTutor
//
//  Created by Charles Feduke on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FirstLetter.h"


@implementation NSString (FirstLetter)

-(NSString *)BNR_firstLetter {
	if ([self length] < 2) {
		return self;
	}
	
	NSRange r = NSMakeRange(0, 1)
	return [self substringWithRange:r];
}

@end
