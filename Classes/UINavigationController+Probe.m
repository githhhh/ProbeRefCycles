//
//  UINavigationController+Probe.m
//  QYER
//
//  Created by 唐斌 on 15/10/23.
//  Copyright © 2015年 QYER. All rights reserved.
//

#import "UINavigationController+Probe.h"
#import "NSObject+QYSwizzle.h"
#import <objc/runtime.h>
#import "UIViewController+IsDealloc.h"

@implementation UINavigationController (Probe)


+(void)load{
#ifdef DEBUG
    [self swizzleInstanceSelector:@selector(popViewControllerAnimated:) withNewSelector:@selector(probe_PopViewControllerAnimated:)];
    
    [self swizzleInstanceSelector:@selector(pushViewController:animated:) withNewSelector:@selector(probe_PushViewController:animated:)];
    
    /**
     *  popTo
     *
     *  @return return value description
     */
    
#endif
    
}

#pragma mark -
#pragma mark - swizzle

#ifdef DEBUG
-(void)probe_PushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if ([self.viewControllers count]>0) {
        UIViewController *lastVC = [self.viewControllers lastObject];
        NSString *ivarName = GetIvarName(lastVC, viewController,lastVC.probeDeepSuperClassLevel);
        viewController.isStrongRef = ivarName?YES:NO;
        if (viewController.isStrongRef) {
            NSLog(@"****[%@]**被[%@]的成员变量[%@]强引用**，在%@ pop后将不会被释放，如有必要，请忽略该条信息.",[viewController class],[lastVC class],ivarName,[viewController class]);
        }
    }
    
    [self probe_PushViewController:viewController animated:animated];
    
    if (viewController.operateCount == 0) {
        ++viewController.operateCount;
    }
}

-(UIViewController *)probe_PopViewControllerAnimated:(BOOL)animated{
    UIViewController *tempVC = [self probe_PopViewControllerAnimated:animated];
    if (tempVC.operateCount == 1) {
        ++tempVC.operateCount;
    }
    [tempVC launchDcTimer];
    return tempVC;
}
#endif

@end
