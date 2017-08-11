//
//  XXXViewController.m
//  ProbeRefCycles
//
//  Created by 唐斌 on 2017/8/11.
//  Copyright © 2017年 X.Y. All rights reserved.
//

#import "XXXViewController.h"
#import "ReactiveCocoa.h"

@interface XXXViewController ()

    @property (copy, nonatomic) void(^abc)(void) ;
    
@end

@implementation XXXViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "警告标识符"
    
    self.abc = ^{
        
        self.title = @"循环引用";
        
        
    };
    
    self.abc();

    
#pragma clang diagnostic pop
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
