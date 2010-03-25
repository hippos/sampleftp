//
//  sampleftpAppDelegate.h
//  sampleftp
//
//  Created by hippos on 10/03/24.
//  Copyright 2010 hippos-lab.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

enum
{
  kSendBufferSize = 32768
};

@interface sampleftpAppDelegate : NSObject<NSApplicationDelegate, NSStreamDelegate>
{
  NSWindow            *window;
  NSProgressIndicator *indicator;
  NSTextField         *statusLabel;
  NSTextField         *displayLabel;
  NSOutputStream      *_remoteOutputStream;
  NSInputStream       *_uploadLocalFilteStream;
  uint8_t             _buffer[kSendBufferSize];
  size_t              _bufferOffset;
  size_t              _bufferLimit;
}

@property (assign) IBOutlet NSWindow            *window;
@property (assign) IBOutlet NSProgressIndicator *indicator;
@property (assign) IBOutlet NSTextField         *statusLabel;
@property (assign) IBOutlet NSTextField         *displayLabel;
@property (nonatomic, retain) NSOutputStream    *_remoteOutputStream;
@property (nonatomic, retain) NSInputStream     *_uploadLocalFilteStream;

- (void) putfile:(NSString *)filename;
- (void) selectUploadFileSheetDidEnd:(NSOpenPanel *)openpanel returnCode:(int)returnCode contextInfo:(id)info;
- (void) didFinishWriteStream:(NSString*)msg;

- (IBAction)upload:(id)sender;
+ (sampleftpAppDelegate *)sharedAppDelegate;

@end
