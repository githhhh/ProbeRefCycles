//
//  NSObject+QYSwizzle.m
//  githhhh
//
//  Created by githhhh on 15/3/11.
//  Copyright (c) 2015年 githhhh. All rights reserved.
//

#import "NSObject+QYSwizzle.h"
#import <objc/runtime.h>

@implementation NSObject (QYSwizzle)

+ (void) swizzleInstanceSelector:(SEL)originalSelector
                 withNewSelector:(SEL)newSelector
{
    Method originalMethod = class_getInstanceMethod(self, originalSelector);
    Method newMethod = class_getInstanceMethod(self, newSelector);
    
    BOOL methodAdded = class_addMethod([self class],
                                       originalSelector,
                                       method_getImplementation(newMethod),
                                       method_getTypeEncoding(newMethod));
    
    if (methodAdded) {
        class_replaceMethod([self class],
                            newSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

+ (void) swizzleSelector:(SEL)originalSelector
         withNewSelector:(SEL)newSelector
               andNewIMP:(IMP)imp{
    
    Method originMethod = class_getInstanceMethod(self, originalSelector);
    const char * methodEncodeType = method_getTypeEncoding(originMethod);
    BOOL methodAdded = class_addMethod(self, newSelector, imp, methodEncodeType);
    
    if (methodAdded) {
        Method newMethod = class_getInstanceMethod(self,newSelector);
        method_exchangeImplementations(newMethod, originMethod);
    }else{
#ifdef DEBUG
        NSLog(@"===swizzleSelector==faile=");
        NSAssert(NO,@"===========swizzleSelector==faile=========");
#endif
    }
}


@end
