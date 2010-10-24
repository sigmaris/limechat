// LimeChat is copyrighted free software by Satoshi Nakagawa <psychs AT limechat DOT net>.
// You can redistribute it and/or modify it under the terms of the GPL version 2 (see the file GPL.txt).

#import <Cocoa/Cocoa.h>


#define RGB(r,g,b)				[NSColor colorWithCalibratedRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r,g,b,a)			[NSColor colorWithCalibratedRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define DEVICE_RGB(r,g,b)		[NSColor colorWithDeviceRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define DEVICE_RGBA(r,g,b,a)	[NSColor colorWithDeviceRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]


@interface NSColor (NSColorHelper)

+ (NSColor*)fromCSS:(NSString*)str;

@end
