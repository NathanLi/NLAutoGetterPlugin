//
//  NOCPropertyModel.m
//  NAutoGetterPlugin
//
//  Created by NathanLi on 14/11/8.
//  Copyright (c) 2014年 NL. All rights reserved.
//

#import "NOCPropertyModel.h"

@interface NOCPropertyModel ()

@property (nonatomic, assign) int test;

@end

@implementation NOCPropertyModel

- (NSString *)getterMethodName {
  if (!_getterMethodName) {
    return self.name;
  }
  return _getterMethodName;
}

- (NSString *)sampleMethod {
  if (!_sampleMethod) {
    _sampleMethod = [NSString stringWithFormat:@"- (%@)%@", self.typeName, self.name];
  }
  return _sampleMethod;
}

- (NSString *)completeMethod {
  if (!_completeMethod) {
    _completeMethod = [NSString stringWithFormat:@"%@ {\n  if (!_%@) {\n    _%@ = nil;\n  }\n  return _%@;\n}\n", self.sampleMethod, self.name, self.name, self.name];
  }
  return _completeMethod;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"\n0x%lx{\n  name: %@\n  typeName: %@\n  getterMethodName: %@\n}", (unsigned long)self, self.name, self.typeName, self.getterMethodName];
}


@end
