//
//  NAutoGetterPluginConfig.m
//  AutoGetterPlugin
//
//  Created by NathanLi on 14/11/2.
//  Copyright (c) 2014年 NL. All rights reserved.
//
#import "NLAutoGetterPluginConfig.h"
#import "NLAutoGetter.h"
#import <Cocoa/Cocoa.h>
@implementation NLAutoGetterPluginConfig

+ (void)setupMenu {
  NSMenuItem *menuItemEdit = [[NSApp mainMenu] itemWithTitle:@"Edit"];
  if (!menuItemEdit) return;
  
  NSMenuItem *menuItemFormat = [[menuItemEdit submenu] itemWithTitle:@"Format"];
  NSMenuItem *menuItemAutoGetter = [[NSMenuItem alloc] initWithTitle:@"Auto Getter" action:@selector(autoGetter) keyEquivalent:@"g"];
  [menuItemAutoGetter setTarget:[NLAutoGetter sharedPlugin]];
  NSInteger indexAutoGetter = [[menuItemFormat menu] numberOfItems];
  [[menuItemEdit submenu] insertItem:menuItemAutoGetter atIndex:indexAutoGetter];
  
  [menuItemAutoGetter setKeyEquivalentModifierMask:NSAlternateKeyMask | NSCommandKeyMask];
  [menuItemAutoGetter setEnabled:YES];
}

@end
