//
//  ViewController.m
//  FZInputViewDemo
//
//  Created by Frank on 16/3/10.
//  Copyright © 2016年 Frank. All rights reserved.
//

#import "ViewController.h"
#import "FZInputView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)click:(id)sender
{
    FZInputView *inputView = [FZInputView inputViewWithViewController:self];
    __weak typeof(inputView) weakInputView = inputView;
    inputView.inputCompleteBlock = ^(NSString *text) {
        NSLog(@"get text : %@", text);
        [weakInputView hideAndClear:YES];
    };
    [inputView showInView:self.view];
}

@end
