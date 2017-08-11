//
//  ViewController.m
//  ProbeRefCycles
//
//  Created by githhhh on 15/10/30.
//  Copyright © 2015年 X.Y. All rights reserved.
//

#import "ViewController.h"
#import "XXXViewController.h"

@interface ViewController ()


    @property (strong, nonatomic) XXXViewController* xxVC;
    
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    //ProbeRefCycles
    
}
    
    //没有引用
- (IBAction)pushAction:(id)sender {
    
    XXXViewController *xx = [XXXViewController new];
    [self.navigationController pushViewController:xx animated:YES];
}
    
    //直接引用
- (IBAction)action222:(id)sender {
    
    self.xxVC = [XXXViewController new];
    [self.navigationController pushViewController:self.xxVC animated:YES];
}
    //间接引用
- (IBAction)action333:(id)sender {
    
    self.vvvvc =[XXXViewController new];
    [self.navigationController pushViewController:self.vvvvc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
    
}

@end
