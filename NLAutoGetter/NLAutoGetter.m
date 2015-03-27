//
//  NLAutoGetter.m
//  NLAutoGetter
//
//  Created by NathanLi on 14/11/19.
//    Copyright (c) 2014年 NL. All rights reserved.
//

#import "NLAutoGetter.h"
#import "NSTextView+NLCursor.h"
#import "NSString+NLProperty.h"
#import "NLAutoGetterPluginConfig.h"
#import "SharedXcode.h"
#import "NOCPropertyModel.h"

static NLAutoGetter *sharedPlugin;

@interface NLAutoGetter()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@end

@implementation NLAutoGetter

- (void)autoGetter {
  NSURL *url = [SharedXcode currentFilePath];
  NSString *filePath = [url path];
  NSString *fileName = [filePath lastPathComponent];
  NSString *fileExtension = [filePath pathExtension];
  if ([fileName rangeOfString:@"+"].location != NSNotFound) {
    /**
     *  @brief  如果是分类的话，就不生成自动策略
     */
    return;
  }
  
  if (![fileExtension isEqualToString:@"h"]
      && ![fileExtension isEqualToString:@"m"]
      && ![fileExtension isEqualToString:@"mm"]) {
    return;
  }
  
  NSTextView *textView = [SharedXcode textView];
  NSString *text = [textView nl_currentString];
  NSArray *properties = [text properties];
  if ([properties count] == 0) return;
  
  NSString *className = [fileName substringToIndex:[fileName rangeOfString:@"."].location];
  NSString *implementionFilePath = nil;
  if ([fileExtension isEqualToString:@"m"]
      || [fileExtension isEqualToString:@"mm"]) {
    /**
     *  @brief  当前在m文件中。目前是直接把getter方法写到文件中，不应该这么做，而应该是直接复制到当前文件中即可
     */
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    implementionFilePath = filePath;
    if ([fileManager fileExistsAtPath:implementionFilePath]) {
      NSURL *urlImpleFilePath = [NSURL fileURLWithPath:implementionFilePath];
      NSString *fileContent = [NSString stringWithContentsOfURL:urlImpleFilePath encoding:NSUTF8StringEncoding error:NULL];
      NSString *contents = [self insertModels:properties className:className origText:fileContent];
      [contents writeToURL:urlImpleFilePath atomically:NO encoding:NSUTF8StringEncoding error:NULL];
    }
    
  } else {
    /**
     *  @brief  当前在头文件中，直接把getter方法写到m文件中
     */
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    implementionFilePath = [filePath stringByReplacingOccurrencesOfString:@"h" withString:@"m" options:NSBackwardsSearch range:NSMakeRange([filePath length] - 2, 2)];
    if ([fileManager fileExistsAtPath:implementionFilePath]) {
      NSURL *urlImpleFilePath = [NSURL fileURLWithPath:implementionFilePath];
      NSString *fileContent = [NSString stringWithContentsOfURL:urlImpleFilePath encoding:NSUTF8StringEncoding error:NULL];
      NSString *contents = [self insertModels:properties className:className origText:fileContent];
      [contents writeToURL:urlImpleFilePath atomically:NO encoding:NSUTF8StringEncoding error:NULL];
    }
  }
}

- (NSString *)insertModels:(NSArray *)models className:(NSString *)className origText:(NSString *)origText {
  NSMutableString *text = nil;
  if ([models count] == 0) return nil;
  
  NSString *patternClassDefine = [NSString stringWithFormat:@"\\s*@implementation %@\\s*", className];
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:patternClassDefine options:0 error:NULL];
  NSRange rangeClassDefine = [regex rangeOfFirstMatchInString:origText options:0 range:NSMakeRange(0, [origText length])];
  if (rangeClassDefine.location == NSNotFound) {
    return nil;
  }
  
  /**
   *  @brief  检测是否有@end
   */
  NSString *patternClassDefineEnd = [NSString stringWithFormat:@"\\s*@end\\s*$"];
  NSRegularExpression *regexEnd = [NSRegularExpression regularExpressionWithPattern:patternClassDefineEnd options:0 error:NULL];
  NSRange rangeEnd = NSMakeRange(NSMaxRange(rangeClassDefine), [origText length] - NSMaxRange(rangeClassDefine));
  NSRange rangeClassDefineEnd = [regexEnd rangeOfFirstMatchInString:origText options:0 range:rangeEnd];
  if (rangeClassDefineEnd.location == NSNotFound) {
    return nil;
  }
  
  text = [NSMutableString stringWithString:origText];
  __block NSUInteger locationAutoGetter = NSMaxRange(rangeClassDefine);
  
  [models enumerateObjectsUsingBlock:^(NOCPropertyModel *propertyModel, NSUInteger idx, BOOL *stop) {
    if ([self isExistModel:propertyModel inText:text]) {
      return ;
    }
    
    [text insertString:@"\n" atIndex:locationAutoGetter];
    if (idx != 0) {
      locationAutoGetter++;
    }
    
    NSString *getterMethod = [propertyModel completeMethod];
    [text insertString:getterMethod atIndex:locationAutoGetter];
    locationAutoGetter += [getterMethod length];
  }];
  
  return text;
}

- (BOOL)isExistModel:(NOCPropertyModel *)propertyModel inText:(NSString *)origText {
  if (!propertyModel || !origText) return NO;
  
  NSString *typeName = [propertyModel.typeName stringByReplacingOccurrencesOfString:@"*" withString:@"\\s*\\*"];
  NSString *pattern = [NSString stringWithFormat:@"\\s*-\\s*\\(\\s*%@\\s*\\)\\s*%@\\s*", typeName, propertyModel.getterMethodName]
  ;
  NSRegularExpression *regexPropertyGetter = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
  NSUInteger number = [regexPropertyGetter numberOfMatchesInString:origText options:0 range:NSMakeRange(0, [origText length])];
  return number > 0;
}

#pragma mark - Life cycle
+ (void)pluginDidLoad:(NSBundle *)plugin
{
  static dispatch_once_t onceToken;
  NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
  if ([currentApplicationName isEqual:@"Xcode"]) {
    dispatch_once(&onceToken, ^{
      sharedPlugin = [[self alloc] initWithBundle:plugin];
    });
  }
}

+ (instancetype)sharedPlugin
{
  return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
  if (self = [super init]) {
    self.bundle = plugin;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      [NLAutoGetterPluginConfig setupMenu];
    });
  }
  return self;
}


- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end