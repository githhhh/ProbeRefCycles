//
//  UIViewController+IsDealloc.m
//  githhhh
//
//  Created by githhhh on 15/10/23.
//  Copyright © 2015年 githhhh. All rights reserved.
//

#import "UIViewController+IsDealloc.h"
#import "NSObject+QYSwizzle.h"

#define Debugger()    { kill( getpid(), SIGINT ) ; }
#define GetStringFromChar(cr)  [NSString stringWithFormat:@"%s",cr]

#ifdef DEBUG
@interface UIViewController(){
    
}
@property (nonatomic,assign) BOOL isDelloc;
@property (nonatomic,copy)NSString *vcName;
@end

static  const char *operateCountKey = "operateCountKey";
static  const char *isStrongRefKey = "isStrongRefKey";
static  const char *isDellocKey = "isDellocKey";
static  const char *vcNameKey = "vcNameKey";
static const CGFloat operateTime = 2;
#endif

@implementation UIViewController (IsDealloc)


+(void)load{
#ifdef DEBUG
    [self swizzleInstanceSelector:NSSelectorFromString(@"dealloc") withNewSelector:@selector(checkDealloc)];
    
    [self swizzleInstanceSelector:@selector(dismissViewControllerAnimated:completion:) withNewSelector:@selector(idc_DismissViewControllerAnimated:completion:)];
    [self swizzleInstanceSelector:@selector(presentViewController:animated:completion:) withNewSelector:@selector(idc_PresentViewController:animated:completion:)];
    
    [self swizzleInstanceSelector:@selector(presentModalViewController:animated:) withNewSelector:@selector(idc_PresentModalViewController:animated:)];
    [self swizzleInstanceSelector:@selector(dismissModalViewControllerAnimated:) withNewSelector:@selector(idc_DismissModalViewControllerAnimated:)];
#endif

}

-(void)launchDcTimer{
#ifdef DEBUG
    if (self.operateCount != 2) {
        return;
    }
    if (self.isStrongRef) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    self.isDelloc = NO;
    self.vcName =  GetStringFromChar(object_getClassName(self));
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(operateTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (weakSelf&&!weakSelf.isDelloc) {
            /**
             *  在这直接写断言 在没有引用循环时，会延时好一会才会调用 delloc 。。妹的。。
             */
            [weakSelf action];
        }
    });
#endif

}


-(void)action{
#ifdef DEBUG
    NSString *msg = [NSString stringWithFormat:@"%@ 没有被释放，在被navgation 推出后 %f s内，请检查是否存在循环强引用。at:\n%@",self.vcName,operateTime,[NSThread callStackSymbols]];
//    NSLog(@"%@",msg);
    NSLog(@"%@",msg);
    Debugger()
#endif
}

#pragma mark -
#pragma mark -  get && set

#ifdef DEBUG
-(void)setOperateCount:(NSInteger)operateCount{
    objc_setAssociatedObject(self, &operateCountKey, @(operateCount), OBJC_ASSOCIATION_ASSIGN);
}
-(NSInteger)operateCount{
    return  [objc_getAssociatedObject(self, &operateCountKey) integerValue];
}


-(void)setIsDelloc:(BOOL)isDelloc{
    objc_setAssociatedObject(self, &isDellocKey, @(isDelloc), OBJC_ASSOCIATION_ASSIGN);
}
-(BOOL)isDelloc{
    return  [objc_getAssociatedObject(self, &isDellocKey) boolValue];
}


-(void)setVcName:(NSString *)vcName{
    objc_setAssociatedObject(self, &vcNameKey, vcName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(NSString *)vcName{
    return  objc_getAssociatedObject(self, &vcNameKey) ;
}


-(void)setIsStrongRef:(BOOL)isStrongRef{
    objc_setAssociatedObject(self, &isStrongRefKey, @(isStrongRef), OBJC_ASSOCIATION_ASSIGN);
}
-(BOOL)isStrongRef{
    return  [objc_getAssociatedObject(self, &isStrongRefKey) boolValue];
}
#endif

#pragma mark -
#pragma mark - swizzle

#ifdef DEBUG
-(void)idc_DismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion{
    [self idc_DismissViewControllerAnimated:flag completion:completion];
    if (self.operateCount == 1) {
        ++self.operateCount;
    }
    [self launchDcTimer];
}

-(void)idc_PresentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion{
    NSString *ivarName = GetIvarName(self, viewControllerToPresent);
    viewControllerToPresent.isStrongRef = ivarName?YES:NO;
    if (viewControllerToPresent.isStrongRef) {
        NSLog(@"****[%@]**被[%@]的成员变量[%@]强引用**，在%@ dismiss后将不会被释放，如有必要，请忽略该条信息.",[viewControllerToPresent class],[self class],ivarName,[viewControllerToPresent class]);
    }
    [self idc_PresentViewController:viewControllerToPresent animated:flag completion:completion];
    if (viewControllerToPresent.operateCount == 0) {
        ++viewControllerToPresent.operateCount;
    }
}



-(void)idc_PresentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated{
    NSString *ivarName = GetIvarName(self, modalViewController);
    modalViewController.isStrongRef = ivarName?YES:NO;
    if (modalViewController.isStrongRef) {
        NSLog(@"****[%@]**被[%@]的成员变量[%@]强引用**，在%@ dismiss后将不会被释放，如有必要，请忽略该条信息.",[modalViewController class],[self class],ivarName,[modalViewController class]);
    }
    [self idc_PresentModalViewController:modalViewController animated:animated];
    if (modalViewController.operateCount == 0) {
        ++modalViewController.operateCount;
    }
}

-(void)idc_DismissModalViewControllerAnimated:(BOOL)animated{
    [self idc_DismissModalViewControllerAnimated:animated];
    if (self.operateCount == 1) {
        ++self.operateCount;
    }
    [self launchDcTimer];
}


-(void)checkDealloc{
    self.isDelloc = YES;
    [self checkDealloc];
}
#endif

@end
