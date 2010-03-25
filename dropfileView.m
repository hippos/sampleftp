//
//  dropfileView.m
//  sampleftp
//
//  Created by hippos on 10/03/24.
//  Copyright 2010 hippos-lab.com. All rights reserved.
//

#import "dropfileView.h"
#import "sampleftpAppDelegate.h"

@implementation dropfileView

- (id)initWithFrame:(NSRect)frame
{
  self = [super initWithFrame:frame];
  if (self)
  {
    [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    
  }
  return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
  // Drawing code here.
}

- (void)dealloc
{
  [self unregisterDraggedTypes];
  [super dealloc];
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo> )sender
{
  if ((NSDragOperationGeneric & [sender draggingSourceOperationMask]) == NSDragOperationGeneric)
  {
    return NSDragOperationGeneric;
  }
  else
  {
    return NSDragOperationNone;
  }
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
  return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{

  NSArray *files = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
  
  if (files == nil || [files count] == 0)
  {
    return NO;
  }

  [[sampleftpAppDelegate sharedAppDelegate] putfile:[files objectAtIndex:0]];
  return YES;
}
@end
