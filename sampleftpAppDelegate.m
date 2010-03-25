//
//  sampleftpAppDelegate.m
//  sampleftp
//
//  Created by hippos on 10/03/24.
//  Copyright 2010 hippos-lab.com. All rights reserved.
//

#import "sampleftpAppDelegate.h"

@implementation sampleftpAppDelegate

@synthesize window;
@synthesize indicator;
@synthesize statusLabel,displayLabel;
@synthesize _remoteOutputStream = remoteOutputStream;
@synthesize _uploadLocalFilteStream = uploadLocalFilteStream;

+ (sampleftpAppDelegate *)sharedAppDelegate
{
  return (sampleftpAppDelegate *) [[NSApplication sharedApplication] delegate];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification 
{
	[displayLabel setStringValue:NSLocalizedString(@"drag and drop upload file",@"drag and drop upload file")];
  [statusLabel setStringValue:NSLocalizedString(@"ready...",@"ready...")];
  [indicator setHidden:YES];
}

- (IBAction)upload:(id)sender
{
  NSOpenPanel *opanel = [NSOpenPanel openPanel];
  
  [opanel setCanChooseFiles:YES];
  [opanel setCanCreateDirectories:NO];
  
  [opanel beginSheetForDirectory:NSHomeDirectory() file:nil
                  modalForWindow:[NSApp mainWindow]  modalDelegate:self
                  didEndSelector:@selector(selectUploadFileSheetDidEnd:returnCode:contextInfo:)contextInfo:nil];
}

- (void) selectUploadFileSheetDidEnd:(NSOpenPanel*)openpanel returnCode:(int)returnCode contextInfo:(id)info
{
  if (returnCode == NSCancelButton)
  {
    return;
  }
  [self putfile:[openpanel filename]];
  return;
}

- (void) putfile:(NSString*)filename
{
  CFWriteStreamRef ftpStream;
  NSURL            *url = [NSURL URLWithString:[NSString stringWithFormat:@"ftp://example.com/%@",[filename lastPathComponent]]];

//  url = [NSMakeCollectable(
//           CFURLCreateCopyAppendingPathComponent(NULL, (CFURLRef)url, (CFStringRef) [filename lastPathComponent], false)
//           ) autorelease];

  NSError* err = nil;
  NSDictionary* attr = [[NSFileManager defaultManager] attributesOfItemAtPath:filename error:&err];
  [indicator setMaxValue:[[attr valueForKey:@"NSFileSize"] doubleValue]];
  [indicator setStyle:NSProgressIndicatorBarStyle];
  
  [displayLabel setStringValue:[NSString stringWithFormat:NSLocalizedString(@"upload file_name", @"upload file_name"), [filename lastPathComponent]]];

  uploadLocalFilteStream = [NSInputStream inputStreamWithFileAtPath:filename];
  assert(uploadLocalFilteStream != nil);
  [uploadLocalFilteStream open];

  ftpStream = CFWriteStreamCreateWithFTPURL(NULL, (CFURLRef)url);
  assert(ftpStream != NULL);

  remoteOutputStream = (NSOutputStream *)ftpStream;
  [remoteOutputStream setProperty:@"username" forKey:(id)kCFStreamPropertyFTPUserName];
  [remoteOutputStream setProperty:@"password" forKey:(id)kCFStreamPropertyFTPPassword];
  [remoteOutputStream setDelegate:self];
  [remoteOutputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
  [remoteOutputStream open];

  CFRelease(ftpStream);
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
  switch (eventCode)
  {
    case NSStreamEventOpenCompleted:
      [indicator setHidden:NO];
      [statusLabel setStringValue:NSLocalizedString(@"connected",@"connected")];
      break;
    case NSStreamEventHasBytesAvailable:
      {
      }
      break;
    case NSStreamEventHasSpaceAvailable:
      {
        if (_bufferOffset == _bufferLimit)
        {
          NSInteger bytesRead = [uploadLocalFilteStream read:_buffer maxLength:kSendBufferSize];
          
          if (bytesRead == -1)
          {
            [self didFinishWriteStream:NSLocalizedString(@"upload file read error",@"upload file read error")];
          }
          else if (bytesRead == 0)
          {
            [self didFinishWriteStream:nil];
          }
          else
          {
            _bufferOffset = 0;
            _bufferLimit  = bytesRead;
          }
        }
        if (_bufferOffset != _bufferLimit)
        {
          NSInteger bytesWritten = [remoteOutputStream write:&_buffer[_bufferOffset] maxLength:(_bufferLimit - _bufferOffset)];
          assert(bytesWritten != 0);
          if (bytesWritten == -1)
          {
            [self didFinishWriteStream:NSLocalizedString(@"Network write error",@"Network write error")];
          }
          else
          {
            _bufferOffset += bytesWritten;
            [indicator incrementBy:bytesWritten];
            [statusLabel setStringValue:[NSString stringWithFormat:@"%.0f",[indicator doubleValue]]];
          }
        }
      }
      break;
    case NSStreamEventErrorOccurred:
      [self didFinishWriteStream:NSLocalizedString(@"Stream event error",@"Stream event error")];
      break;
    case NSStreamEventEndEncountered:
      [self didFinishWriteStream:nil];
      break;
    default:
      break;
  }
}

- (void) didFinishWriteStream:(NSString*)msg
{
  if (remoteOutputStream != nil)
  {
    [remoteOutputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [remoteOutputStream setDelegate:nil];
    [remoteOutputStream close];
    remoteOutputStream = nil;
  }

  if (uploadLocalFilteStream != nil)
  {
    [uploadLocalFilteStream close];
    uploadLocalFilteStream = nil;
  }
  if (msg == nil)
  {
    [statusLabel setStringValue:NSLocalizedString(@"completed",@"completed")];
  }
  else
  {
    [statusLabel setStringValue:msg];
  }
  [indicator stopAnimation:self];
  [indicator setHidden:YES];
	[displayLabel setStringValue:NSLocalizedString(@"drag and drop upload file",@"drag and drop upload file")];
}

@end
