//
//  UIViewController+IsDealloc.h
//  QYER
//
//  Created by 唐斌 on 15/10/23.
//  Copyright © 2015年 QYER. All rights reserved.
//
//  * DeBug 下 探测 循环引用  可以忽略~ *
//  * 只适用于  viewcontroller  在 navigation 中出栈入栈 。*


/** target  run pre-actions shell scripte
 
 #Grabs info from plist
 plist=$SRCROOT"/"$INFOPLIST_FILE
 currentBuild=`/usr/libexec/PlistBuddy -c "Print :IsLaunchFromXcode" "$plist"`
 
 #是否存在
 if [ -z "$currentBuild" ];
 then
 
 #不存在
 currentBuild=YES
 /usr/libexec/PlistBuddy -c "Add :IsLaunchFromXcode bool $currentBuild" "$plist"
 
 else
 
 #存在
 if [ $currentBuild == "true" ];
 then
 currentBuild=NO
 else
 currentBuild=YES
 fi
 
 /usr/libexec/PlistBuddy -c "Set :IsLaunchFromXcode $currentBuild" "$plist"
 
 fi
 
 */


#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#ifdef DEBUG

enum ProbeDeepSuperClassLevel{
    DefaultDeepLevel = 1,
    DeepAllSuperClassLevel = 100
};

typedef  NSInteger ProbeDeepSuperClassLevel;

/**
 *  判断（ivarInstance）是否（被holdInstance）引用
 *
 *  @param holdInstance holdInstance description
 *  @param ivarInstance ivarInstance description
 *  @param deepLevel    deepLevel description
 *
 *  @return 引用的变量名
 */
static id GetIvarName(id holdInstance, id ivarInstance ,ProbeDeepSuperClassLevel deepLevel)
{
    if (!holdInstance || !ivarInstance) {
        return nil;
    }
    //默认deep一级向上
    if (deepLevel == 0) {
        deepLevel = DefaultDeepLevel;
    }
    NSString *ivarName = nil;
    BOOL isFinde = NO;
    int deepCount = 0;
    
    //查找继承链
    Class currentClass = [holdInstance class];
    while (currentClass) {
        //只查找业务类,如果deep到UIViewControl原生类,跳出。
        if ([NSStringFromClass(currentClass) isEqualToString:@"UIViewController"]) {
            break;
        }
        
        uint32_t ivarCount;
        Ivar *ivars = class_copyIvarList(currentClass, &ivarCount);
        if (ivars) {
            for (uint32_t i = 0; i < ivarCount; i++) {
                Ivar ivar = ivars[i];
                const char *ivarType = ivar_getTypeEncoding(ivar);
                NSString *ivarTypeStr = [NSString stringWithCString:ivarType encoding:NSUTF8StringEncoding];
                //成员变量不是object 调用object_getIvar 会crash
                if (![ivarTypeStr hasPrefix:@"@"]) {
                    continue;
                }
                id pointer = object_getIvar(holdInstance, ivar);
                if (pointer == ivarInstance) {
                    ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
                    isFinde = YES;
                    break;
                }
            }
            
            free(ivars);
        }
        if (isFinde) {
            break;
        }
        /**
         *  默认最多向上查找一级父类。。
         */
        if (deepCount == deepLevel) {
            break;
        }
        currentClass = [currentClass superclass];
        deepCount++;
    }
    return ivarName;
}

#endif



#ifdef DEBUG

@interface NSObject (IsLaunchFromXcode)

+(BOOL)isLaunchFromXcode;

@end



@interface UIViewController (IsDealloc)


@property (nonatomic,assign) NSInteger operateCount;
@property (nonatomic,assign) BOOL isStrongRef;
@property (nonatomic,assign) ProbeDeepSuperClassLevel probeDeepSuperClassLevel;
/**
 *  启用计时器
 */
-(void)launchDcTimer;

@end

#endif