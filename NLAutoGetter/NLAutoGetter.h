//
//  NLAutoGetter.h
//  NLAutoGetter
//
//  Created by NathanLi on 14/11/19.
//  Copyright (c) 2014年 NL. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface NLAutoGetter : NSObject

+ (instancetype)sharedPlugin;
- (void)autoGetter;
@property (nonatomic, strong, readonly) NSBundle* bundle;
@end