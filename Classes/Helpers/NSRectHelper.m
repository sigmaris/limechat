// LimeChat is copyrighted free software by Satoshi Nakagawa <psychs AT limechat DOT net>.
// You can redistribute it and/or modify it under the terms of the GPL version 2 (see the file GPL.txt).

#import "NSRectHelper.h"


NSPoint NSRectCenter(NSRect rect)
{
	return NSMakePoint(rect.origin.x + rect.size.width/2, rect.origin.y + rect.size.height/2);
}

NSRect NSRectAdjustInRect(NSRect r, NSRect bounds)
{
	if (NSMaxX(bounds) < NSMaxX(r)) {
		r.origin.x = NSMaxX(bounds) - r.size.width;
	}
	if (NSMaxY(bounds) < NSMaxY(r)) {
		r.origin.y = NSMaxY(bounds) - r.size.height;
	}
	if (r.origin.x < bounds.origin.x) {
		r.origin.x = bounds.origin.x;
	}
	if (r.origin.y < bounds.origin.y) {
		r.origin.y = bounds.origin.y;
	}
	return r;
}
