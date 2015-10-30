//
//  UIViewController+IsDealloc.h
//  githhhh
//
//  Created by githhhh on 15/10/23.
//  Copyright © 2015年 githhhh. All rights reserved.
//

/**
 *  DeBug 下 探测 循环引用  可以忽略~
 *  只适用于  viewcontroller  在 navigation 中出栈入栈 。
 */

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static id GetIvarName(id holdInstance,id ivarInstance){
    if (!holdInstance||!ivarInstance) {
        return nil;
    }
    
    NSString *ivarName = nil;
    uint32_t ivarCount;
    Ivar *ivars = class_copyIvarList([holdInstance class], &ivarCount);
    if(ivars)
    {
        for(uint32_t i=0; i<ivarCount; i++)
        {
            Ivar ivar = ivars[i];
            const char*ivarType = ivar_getTypeEncoding(ivar);
            NSString *ivarTypeStr = [NSString stringWithCString:ivarType encoding:NSUTF8StringEncoding];
            //成员变量不是object 调用object_getIvar 会crash
            if (![ivarTypeStr hasPrefix:@"@"]) {
                continue;
            }
            
            id pointer = object_getIvar(holdInstance, ivar);
            
            if(pointer == ivarInstance)
            {
                ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
                break;
            }
        }
        
        free(ivars);
    }
    return  ivarName;
}


@interface UIViewController (IsDealloc)

#ifdef DEBUG
@property (nonatomic,assign) NSInteger operateCount;
@property (nonatomic,assign) BOOL isStrongRef;
/**
 *  启用计时器
 */
-(void)launchDcTimer;
#endif

@end 
