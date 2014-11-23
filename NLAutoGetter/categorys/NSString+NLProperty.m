//
//  NSString+NLProperty.m
//  NAutoGetterPlugin
//
//  Created by NathanLi on 14/11/11.
//  Copyright (c) 2014年 NL. All rights reserved.
//

#import "NSString+NLProperty.h"
#import "NOCPropertyModel.h"

@implementation NSString (NLProperty)

- (NSString *)stringByTrimmingMoreThanOneSubString:(NSString *)subString {
  NSString *pattern = [NSString stringWithFormat:@"%@{1,}", subString];
  NSRegularExpression *regular = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:NULL];
  NSString *result = [regular stringByReplacingMatchesInString:self options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(0, [self length]) withTemplate:subString];
  return result;
}

- (NSArray *)properties {
  NSArray *propertyStrs = [self componentsSeparatedByString:@";"];
  NSMutableArray *properties = [NSMutableArray array];
  
  [propertyStrs enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
    if ([obj length] < 5) {
      return ;
    }
    
    NSString *str = [obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![str hasPrefix:@"@property"]) {
      return;
    }
    
    NOCPropertyModel *propertyModel = [str propertyModel];
    if (propertyModel) {
      [properties addObject:propertyModel];
    }
  }];
  
  if ([properties count] > 0) {
    return properties;
  }
  
  return nil;
}

#pragma mark - private methods
/**
 *  @brief 返回当前字符中的属性
 */
- (NOCPropertyModel *)propertyModel {
  NSString *str = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  str = [self stringByTrimmingMoreThanOneSubString:@" "];
  if (![str hasPrefix:@"@property"]) {
    return nil;
  }
  
  /**
   *  @brief  最多只有一个“*”
   */
  NSRange rangeStar = [str rangeOfString:@"*"];
  if (rangeStar.location != NSNotFound) {
    NSUInteger location = rangeStar.location + 1;
    NSUInteger length = [self length] - location;
    if ([str rangeOfString:@"*" options:0 range:NSMakeRange(location, length)].location != NSNotFound) {
      return nil;
    }
  }
  
  NSString *augGetter = [str nl_propertyAugGetterName];
  
  NSString *modelStr = [str nl_propertyAugModelStr];
  /**
   *  @brief  NSBundle*bundle 替换为 “NSBundle* bundle”
   */
  modelStr = [modelStr stringByTrimmingMoreThanOneSubString:@" "];
  modelStr = [modelStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

  NSArray *modelAugs = [modelStr componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  if ([modelStr rangeOfString:@"*"].location != NSNotFound) {
    modelAugs = [modelStr componentsSeparatedByString:@"*"];
  }
  
  if ([modelAugs count] > 2) {
    return nil;
  }
  
  NSString *typeName = [modelAugs[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  if ([modelStr rangeOfString:@"*"].location != NSNotFound) {
    typeName = [typeName stringByAppendingString:@" *"];
  }
  
  NSString *modelName = [modelAugs[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  if (typeName == nil || modelName == nil) {
    return nil;
  }
  
  NOCPropertyModel *property = [[NOCPropertyModel alloc] init];
  property.name = modelName;
  property.typeName = typeName;
  property.getterMethodName = augGetter;
  
  return property;
}

/**
 *  @brief 返回属性定义中的参数字符串
 *         如@property (nonatomic, strong, readonly) NSBundle* bundle;中
 *         返回 nonatomic, strong, readonly
 */
- (NSString *)nl_propertyAugStr {
  NSRange leftBracketRange = [self rangeOfString:@"("];
  NSRange rightBracketRange = [self rangeOfString:@")"];
  if (leftBracketRange.location == NSNotFound || rightBracketRange.location == NSNotFound
      || rightBracketRange.location < leftBracketRange.location - 4 || leftBracketRange.location < 8) {
    return nil;
  }
  
  NSUInteger len = rightBracketRange.location - leftBracketRange.location - 1;
  NSRange rangeAugStr = NSMakeRange(leftBracketRange.location + 1, len);
  NSString *augStr = [self substringWithRange:rangeAugStr];
  
  return augStr;
}


/**
 *  @brief 返回属性定义中的参数字符串
 *         如@property (nonatomic, strong, getter = bundle, readonly) NSBundle* bundle;中
 *         返回 bundle
 */
- (NSString *)nl_propertyAugGetterName {
  NSString *augStr = [self nl_propertyAugStr];
  __block NSString *augGetterName = nil;
  if (augStr) {
    NSArray *augs = [augStr componentsSeparatedByString:@","];
    [augs enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
      NSString *aug = [obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
      if ([aug hasPrefix:@"getter"]) {
        NSArray *getterAugs = [aug componentsSeparatedByString:@"="];
        
        /**
         *  @brief  去掉=两边的空白字符
         */
        for (NSString *obj in getterAugs) {
          NSString *getterAug = [obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
          if (![getterAug isEqualToString:@"getter"]) {
            augGetterName = getterAug;
            *stop = YES;
            break;
          }
        }
      }
    }];
  }
  
  return augGetterName;
}

/**
 *  @brief 返回属性定义中的属性字符串
 *         如@property (nonatomic, strong, getter = bundle, readonly) NSBundle* bundle;中
 *         返回 NSBundle* bundle
 */
- (NSString *)nl_propertyAugModelStr {
  NSString *modelStr = nil;
  NSRange rangeModelStr;
  NSString *augStr = [self nl_propertyAugStr];
  if (augStr) {
    NSRange rangeAutStr = [self rangeOfString:augStr];
    NSUInteger location = NSMaxRange(rangeAutStr) + 1;
    rangeModelStr = NSMakeRange(location, [self length] - location);
  } else {
    NSRange rangeProperty = [self rangeOfString:@"@property "];
    if (rangeProperty.location == NSNotFound) {
      return nil;
    }
    NSUInteger location = NSMaxRange(rangeProperty);
    rangeModelStr = NSMakeRange(location, [self length] - location);
  }
  
  modelStr = [self substringWithRange:rangeModelStr];
  
  return modelStr;
}



@end
