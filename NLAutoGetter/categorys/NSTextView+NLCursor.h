//
//  NSTextView+NLCursor.h
//  AutoGetterPlugin
//
//  Created by NathanLi on 14/11/3.
//  Copyright (c) 2014年 NL. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSTextView (NLCursor)


- (NSInteger)nl_currentCursorLocation;

/**
 *  @brief 鼠标所在行的 string
 */
- (NSString *)nl_stringOfCurrentLine;

/**
 *  @brief  选择的 string
 */
- (NSString *)nl_selectedString;

/**
 *  @brief  所选择的完整的字符串
 */
- (NSString *)nl_selectedFullSting;

/**
 *  @brief 如果有选择文本，则返回选择的文本内容。如果没有选择文本，则返回鼠标所在行的文本
 */
- (NSString *)nl_currentString;

@end
