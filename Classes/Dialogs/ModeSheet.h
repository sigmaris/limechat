// LimeChat is copyrighted free software by Satoshi Nakagawa <psychs AT limechat DOT net>.
// You can redistribute it and/or modify it under the terms of the GPL version 2 (see the file GPL.txt).

#import <Foundation/Foundation.h>
#import "SheetBase.h"
#import "IRCChannelMode.h"


@interface ModeSheet : SheetBase
{
	IRCChannelMode* mode;
	NSString* channelName;
	int uid;
	int cid;
	
	IBOutlet NSButton* sCheck;
	IBOutlet NSButton* pCheck;
	IBOutlet NSButton* nCheck;
	IBOutlet NSButton* tCheck;
	IBOutlet NSButton* iCheck;
	IBOutlet NSButton* mCheck;
	IBOutlet NSButton* aCheck;
	IBOutlet NSButton* rCheck;
	IBOutlet NSButton* kCheck;
	IBOutlet NSButton* lCheck;
	IBOutlet NSTextField* kText;
	IBOutlet NSTextField* lText;
}

@property (nonatomic, retain) IRCChannelMode* mode;
@property (nonatomic, retain) NSString* channelName;
@property (nonatomic, assign) int uid;
@property (nonatomic, assign) int cid;

- (void)start;

- (void)onChangeCheck:(id)sender;

@end


@interface NSObject (ModeSheetDelegate)
- (void)modeSheetOnOK:(ModeSheet*)sender;
- (void)modeSheetWillClose:(ModeSheet*)sender;
@end
