//
//  NSString+NLProperty.h
//  NAutoGetterPlugin
//
//  Created by NathanLi on 14/11/11.
//  Copyright (c) 2014年 NL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NLProperty)
/**
 *  @brief 返回当前字符串中的属性
 */
- (NSArray *)properties;

/**
 *  @brief  删除字符串中的连续重复的同一字符，真到保留最后一个
 *
 *  @param subString
 *
 *  @return
 */
- (NSString *)stringByTrimmingMoreThanOneSubString:(NSString *)subString;
@end
