//
//  ViewController.m
//  Demo-OC
//
//  Created by Klaus on 2018/5/18.
//  Copyright © 2018年 KlausLiu. All rights reserved.
//

#import "ViewController.h"
@import Toast;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toast:(id)sender {
    [KLToast show:@"To be, or not to be: that is the question.To be, or not to be: that is the question.To be, or not to be: that is the question."
         duration:5];
}

- (IBAction)countinuous:(id)sender {
    [KLToast show:@"第一个toast"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [KLToast show:@"第二个toast"];
    });
}

@end
