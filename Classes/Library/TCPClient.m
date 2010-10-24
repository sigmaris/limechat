// LimeChat is copyrighted free software by Satoshi Nakagawa <psychs AT limechat DOT net>.
// You can redistribute it and/or modify it under the terms of the GPL version 2 (see the file GPL.txt).

#import "TCPClient.h"


#define LF	0xa
#define CR	0xd


@interface TCPClient (Private)
- (BOOL)checkTag:(AsyncSocket*)sock;
- (void)waitRead;
@end


@implementation TCPClient

@synthesize delegate;

@synthesize host;
@synthesize port;
@synthesize useSSL;

@synthesize useSystemSocks;
@synthesize useSocks;
@synthesize socksVersion;
@synthesize proxyHost;
@synthesize proxyPort;
@synthesize proxyUser;
@synthesize proxyPassword;
@synthesize sendQueueSize;

@synthesize active;
@synthesize connecting;

- (id)init
{
	if (self = [super init]) {
		buffer = [NSMutableData new];
	}
	return self;
}

- (id)initWithExistingConnection:(AsyncSocket*)socket
{
	[self init];
	
	conn = [socket retain];
	conn.delegate = self;
	[conn setUserData:tag];
	active = connecting = YES;
	sendQueueSize = 0;
	
	return self;
}

- (void)dealloc
{
	[host release];
	[proxyHost release];
	[proxyUser release];
	[proxyPassword release];
	
	if (conn) {
		conn.delegate = nil;
		[conn disconnect];
		[conn autorelease];
	}
	[buffer release];
	
	[super dealloc];
}

- (void)open
{
	[self close];
	
	[buffer setLength:0];
	++tag;
	
	conn = [[AsyncSocket alloc] initWithDelegate:self userData:tag];
	[conn connectToHost:host onPort:port error:NULL];
	active = connecting = YES;
	sendQueueSize = 0;
}

- (void)close
{
	if (!conn) return;
	
	++tag;
	
	[conn disconnect];
	[conn autorelease];
	conn = nil;
	
	active = connecting = NO;
	sendQueueSize = 0;
}

- (NSData*)read
{
	NSData* result = [buffer autorelease];
	buffer = [NSMutableData new];
	return result;
}

- (NSData*)readLine
{
	int len = [buffer length];
	if (!len) return nil;
	
	const char* bytes = [buffer bytes];
	char* p = memchr(bytes, LF, len);
	if (!p) return nil;
	int n = p - bytes;
	
	if (n > 0) {
		char prev = *(p - 1);
		if (prev == CR) {
			--n;
		}
	}
	
	NSMutableData* result = [buffer autorelease];
	
	++p;
	if (p < bytes + len) {
		buffer = [[NSMutableData alloc] initWithBytes:p length:bytes + len - p];
	}
	else {
		buffer = [NSMutableData new];
	}
	
	[result setLength:n];
	return result;
}

- (void)write:(NSData*)data
{
	if (![self connected]) return;
	
	++sendQueueSize;
	
	[conn writeData:data withTimeout:-1 tag:0];
	[self waitRead];
}

- (BOOL)connected
{
	if (!conn) return NO;
	if (![self checkTag:conn]) return NO;
	return [conn isConnected];
}

- (BOOL)onSocketWillConnect:(AsyncSocket*)sender
{
	if (useSystemSocks) {
		[conn useSystemSocksProxy];
	}
	else if (useSocks) {
		[conn useSocksProxyVersion:socksVersion host:proxyHost port:proxyPort user:proxyUser password:proxyPassword];
	}
	else if (useSSL) {
		[conn useSSL];
	}
	return YES;
}

- (void)onSocket:(AsyncSocket *)sender didConnectToHost:(NSString *)aHost port:(UInt16)aPort
{
	if (![self checkTag:sender]) return;
	[self waitRead];
	connecting = NO;
	
	if ([delegate respondsToSelector:@selector(tcpClientDidConnect:)]) {
		[delegate tcpClientDidConnect:self];
	}
}

- (void)onSocket:(AsyncSocket*)sender willDisconnectWithError:(NSError*)error
{
	if (![self checkTag:sender]) return;
	if (!error) return;
	
	NSString* msg = nil;
	
	if ([[error domain] isEqualToString:NSPOSIXErrorDomain]) {
		msg = [AsyncSocket posixErrorStringFromErrno:[error code]];
	}
	
	if (!msg) {
		msg = [error localizedDescription];
	}
	
	if ([delegate respondsToSelector:@selector(tcpClient:error:)]) {
		[delegate tcpClient:self error:msg];
	}
}

- (void)onSocketDidDisconnect:(AsyncSocket*)sender
{
	if (![self checkTag:sender]) return;
	
	[self close];
	
	if ([delegate respondsToSelector:@selector(tcpClientDidDisconnect:)]) {
		[delegate tcpClientDidDisconnect:self];
	}
}

- (void)onSocket:(AsyncSocket *)sender didReadData:(NSData *)data withTag:(long)aTag
{
	if (![self checkTag:sender]) return;
	
	[buffer appendData:data];
	
	if ([delegate respondsToSelector:@selector(tcpClientDidReceiveData:)]) {
		[delegate tcpClientDidReceiveData:self];
	}

	[self waitRead];
}

- (void)onSocket:(AsyncSocket*)sender didWriteDataWithTag:(long)aTag
{
	if (![self checkTag:sender]) return;
	
	--sendQueueSize;
	
	if ([delegate respondsToSelector:@selector(tcpClientDidSendData:)]) {
		[delegate tcpClientDidSendData:self];
	}
}

- (BOOL)checkTag:(AsyncSocket*)sock
{
	return tag == [sock userData];
}

- (void)waitRead
{
	[conn readDataWithTimeout:-1 tag:0];
}

@end
