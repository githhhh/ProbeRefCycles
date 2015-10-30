//
//  NSObject+QYSwizzle.h
//  githhhh
//
//  Created by githhhh on 15/3/11.
//  Copyright (c) 2015年 githhhh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (QYSwizzle)
+ (void)swizzleInstanceSelector:(SEL)originalSelector
                withNewSelector:(SEL)newSelector;

+ (void) swizzleSelector:(SEL)originalSelector
         withNewSelector:(SEL)newSelector
               andNewIMP:(IMP)imp;
@end
