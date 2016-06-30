//
//  KCInputView.h
//  FZInputViewDemo
//
//  Created by Frank on 16/3/10.
//  Copyright © 2016年 Frank. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^InputCompleteBlock)(NSString *text);

@interface FZInputView : UIView
//输入字数限制,默认500
@property (nonatomic, assign) NSInteger textLengthLimit;
//输入完成的回调
@property (nonatomic, copy) InputCompleteBlock inputCompleteBlock;

+ (instancetype)inputViewWithViewController:(UIViewController *)viewController;

- (void)showInView:(UIView *)view;

- (void)hideAndClear:(BOOL)clear;

@end
