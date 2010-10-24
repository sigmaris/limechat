// LimeChat is copyrighted free software by Satoshi Nakagawa <psychs AT limechat DOT net>.
// You can redistribute it and/or modify it under the terms of the GPL version 2 (see the file GPL.txt).

#import "NSDataHelper.h"


@implementation NSData (NSDataHelper)

- (BOOL)isValidUTF8
{
	int len = [self length];
	const unsigned char* bytes = [self bytes];
	
	int rest = 0;
	int code = 0;
	NSRange range;
	
	for (int i=0; i<len; i++) {
		unsigned char c = bytes[i];
		
		if (rest <= 0) {
			if (0x1 <= c && c <= 0x7F) {
				rest = 0;
			}
			else if (0xC0 <= c && c <= 0xDF) {
				rest = 1;
				code = c & 0x1F;
				range = NSMakeRange(0x00080, 0x000800 - 0x00080);
			}
			else if (0xE0 <= c && c <= 0xEF) {
				rest = 2;
				code = c & 0x0F;
				range = NSMakeRange(0x00800, 0x010000 - 0x00800);
			}
			else if (0xF0 <= c && c <= 0xF7) {
				rest = 3;
				code = c & 0x07;
				range = NSMakeRange(0x10000, 0x110000 - 0x10000);
			}
			else {
				return NO;
			}
		}
		else if (0x80 <= c && c <= 0xBF) {
			code = (code << 6) | (c & 0x3F);
			if (--rest <= 0) {
				if (!NSLocationInRange(code, range) || (0xD800 <= code && code <= 0xDFFF)) {
					return NO;
				}
			}
		}
		else {
			return NO;
		}
	}
	
	return YES;
}

- (NSString*)validateUTF8
{
	return [self validateUTF8WithCharacter:0x3F];
}

- (NSString*)validateUTF8WithCharacter:(UniChar)malformChar
{
	int len = [self length];
	const unsigned char* bytes = [self bytes];

	UniChar buf[len];
	int n = 0;

	int rest = 0;
	int code = 0;
	NSRange range;
	
	for (int i=0; i<len; i++) {
		unsigned char c = bytes[i];
		
		if (rest <= 0) {
			if (0x1 <= c && c <= 0x7F) {
				rest = 0;
				buf[n++] = c;
			}
			else if (0xC0 <= c && c <= 0xDF) {
				rest = 1;
				code = c & 0x1F;
				range = NSMakeRange(0x00080, 0x000800 - 0x00080);
			}
			else if (0xE0 <= c && c <= 0xEF) {
				rest = 2;
				code = c & 0x0F;
				range = NSMakeRange(0x00800, 0x010000 - 0x00800);
			}
			else if (0xF0 <= c && c <= 0xF7) {
				rest = 3;
				code = c & 0x07;
				range = NSMakeRange(0x10000, 0x110000 - 0x10000);
			}
			else {
				buf[n++] = malformChar;
			}
		}
		else if (0x80 <= c && c <= 0xBF) {
			code = (code << 6) | (c & 0x3F);
			if (--rest <= 0) {
				if (!NSLocationInRange(code, range) || (0xD800 <= code && code <= 0xDFFF)) {
					code = malformChar;
				}
				buf[n++] = code;
			}
		}
		else {
			buf[n++] = code;
			rest = 0;
		}
	}
	
	return [[[NSString alloc] initWithCharacters:buf length:n] autorelease];
}

@end
