//
//  NSTextView+NLCursor.m
//  AutoGetterPlugin
//
//  Created by NathanLi on 14/11/3.
//  Copyright (c) 2014年 NL. All rights reserved.
//

#import "NSTextView+NLCursor.h"

@implementation NSTextView (NLCursor)

- (NSString *)nl_currentString {
  NSArray *selectedRanges = [self selectedRanges];
  if ([selectedRanges count] == 0) return nil;
  
  if ([[selectedRanges firstObject] rangeValue].length == 1) {
    return [self nl_stringOfCurrentLine];
  }
  
  return [self nl_selectedFullSting];
}

- (NSString *)nl_selectedString {
  NSArray *selectedRanges = [self selectedRanges];
  if ([selectedRanges count]) {
    NSString *text = self.textStorage.string;
    return [text substringWithRange:[selectedRanges.firstObject rangeValue]];
  }
  
  return nil;
}

- (NSString *)nl_selectedFullSting {
  NSArray *selectedRanges = [self selectedRanges];
  if ([selectedRanges count] == 0) return nil;
  
  NSString *text = self.textStorage.string;
  NSRange selectedRange = [selectedRanges.firstObject rangeValue];
  NSRange beginRange = NSMakeRange(0, selectedRange.location);
  NSRange endRange = NSMakeRange(NSMaxRange(selectedRange), [text length] - NSMaxRange(selectedRange));
  beginRange = [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSBackwardsSearch range:beginRange];
  endRange = [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:0 range:endRange];
  
  NSRange fullRange = NSMakeRange(beginRange.location + 1, endRange.location - beginRange.location - 1);
  if (fullRange.location >= [text length] || NSMaxRange(fullRange) > [text length]) {
    return nil;
  }
  NSString *fullString = [text substringWithRange:fullRange];
  return fullString;
}

- (NSInteger)nl_currentCursorLocation {
  NSArray *selectedRanges = [self selectedRanges];
  return [[selectedRanges firstObject] rangeValue].location;
}

- (NSString *)nl_stringOfCurrentLine {
  NSString *text = self.textStorage.string;
  
  NSInteger cursorLocation = [self nl_currentCursorLocation];
  NSRange range = NSMakeRange(0, cursorLocation);
  NSRange leftRange = [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSBackwardsSearch range:range];
  range = NSMakeRange(cursorLocation, [text length] - cursorLocation);
  NSRange rightRange = [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:0 range:range];
  int length = (int)rightRange.location - (int)leftRange.location;
  NSRange thisLineRange = NSMakeRange(leftRange.location, length);
  
  NSString *lineString = nil;
  if (thisLineRange.location != NSNotFound) {
    NSRange lineRange = NSMakeRange(thisLineRange.location + 1, thisLineRange.length - 1);
    if (lineRange.location < [text length] && NSMaxRange(lineRange) <= [text length]) {
      lineString = [text substringWithRange:lineRange];
    }
  }
  return lineString;
}

@end
