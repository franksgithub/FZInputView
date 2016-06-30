//
//  KCInputView.m
//  FZInputViewDemo
//
//  Created by Frank on 16/3/10.
//  Copyright © 2016年 Frank. All rights reserved.
//

#import "FZInputView.h"
#import <objc/runtime.h>

static const float kMargin = 15.0f;
static const float kTextViewHeight = 100.0f;
static const float kTextViewBgViewHeight = 160.0f;
static const float kTextViewBgViewVisibleHeight = 150.0f;
static char kAssociationViewControllerKey;

@interface FZInputView()<UITextViewDelegate>
{
    UITextView *inputTextView;
    UIView *textViewBgView;
    UIButton *sendButton;
}

@end

@implementation FZInputView

+ (instancetype)inputViewWithViewController:(UIViewController *)viewController
{
    id view = objc_getAssociatedObject(viewController, &kAssociationViewControllerKey);
    if (view) {
        return view;
    }
    else {
        FZInputView *inputView = [[self class] new];
        objc_setAssociatedObject(viewController, &kAssociationViewControllerKey, inputView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return inputView;
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonSetUp];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)commonSetUp
{
    self.textLengthLimit = 500;
    self.alpha = 0.5;
    self.frame = [UIScreen mainScreen].bounds;
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
    effectView.frame = self.frame;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [effectView addGestureRecognizer:tap];
    [self addSubview:effectView];
    
    textViewBgView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - kTextViewBgViewVisibleHeight, self.bounds.size.width, kTextViewBgViewHeight)];
    textViewBgView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self addSubview:textViewBgView];
    
    inputTextView = [[UITextView alloc] initWithFrame:CGRectMake(kMargin, kMargin * 2 + 5, self.bounds.size.width - (kMargin * 2), kTextViewHeight)];
    inputTextView.delegate = self;
    inputTextView.font = [UIFont systemFontOfSize:15];
    [textViewBgView addSubview:inputTextView];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:15];
    cancelButton.frame = CGRectMake(kMargin - 8, 8, 40, 20);
    [cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [textViewBgView addSubview:cancelButton];
    
    sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
    sendButton.enabled = NO;
    sendButton.titleLabel.font = [UIFont systemFontOfSize:15];
    sendButton.frame = CGRectMake(self.frame.size.width - 40 - 8, 8, 40, 20);
    [sendButton addTarget:self action:@selector(send:) forControlEvents:UIControlEventTouchUpInside];
    [textViewBgView addSubview:sendButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)tap:(id)sender
{
    [self hideAndClear:NO];
}

- (void)showInView:(UIView *)view
{
    [view addSubview:self];
    [inputTextView becomeFirstResponder];
}

- (void)hideAndClear:(BOOL)clear
{
    [inputTextView resignFirstResponder];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect frame = textViewBgView.frame;
        frame.origin.y = self.bounds.size.height;
        textViewBgView.frame = frame;
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (clear) {
            inputTextView.text = nil;
        }
    }];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSValue *endframeValue = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect endFrame = endframeValue.CGRectValue;
    NSNumber *duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:duration.floatValue animations:^{
        CGRect frame = textViewBgView.frame;
        frame.origin.y = self.bounds.size.height - kTextViewBgViewVisibleHeight - endFrame.size.height;
        textViewBgView.frame = frame;
        if (self.alpha != 1.0) {
            self.alpha = 1.0;
        }
    }];
}

- (void)cancel:(id)sender
{
    [self hideAndClear:NO];
}

- (void)send:(id)sender
{
    if (self.inputCompleteBlock) {
        self.inputCompleteBlock(inputTextView.text);
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length > 0) {
        sendButton.enabled = YES;
    }
    else {
        sendButton.enabled = NO;
    }
    if (textView.markedTextRange == nil && self.textLengthLimit > 0 && textView.text.length > self.textLengthLimit) {
        textView.text = [textView.text substringToIndex:self.textLengthLimit];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView.text.length >= self.textLengthLimit && text.length > range.length) {
        return NO;
    }
    return YES;
}

@end
