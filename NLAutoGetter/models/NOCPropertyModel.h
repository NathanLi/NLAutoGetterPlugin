//
//  NOCPropertyModel.h
//  NAutoGetterPlugin
//
//  Created by NathanLi on 14/11/8.
//  Copyright (c) 2014年 NL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NOCPropertyModel : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *typeName;
@property (nonatomic, copy) NSString *getterMethodName;

/**
 *  @brief  - (className)name
 */
@property (nonatomic, strong) NSString *sampleMethod;
@property (nonatomic, strong) NSString *completeMethod;
@end
