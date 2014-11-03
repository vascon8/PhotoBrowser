//
//
//  Created by xinliu on 14-10-19.
//  Copyright (c) 2014年 xinliu. All rights reserved.
//

#import "LXLoadingView.h"
#import "LXLoadingProgressView.h"

@interface LXLoadingView ()

@property (weak,nonatomic) LXLoadingProgressView *progressView;
@property (weak,nonatomic) UILabel               *failureLabel;

@end

@implementation LXLoadingView
- (id)init
{
    if(self = [super init]){
        self.frame = [UIScreen mainScreen].applicationFrame;
        self.progress = 0.0;
    }
    return self;
}
+ (instancetype)loadingView
{
    return [[self alloc]init];
}
- (void)showLoading
{
    if (!_progressView) {
        LXLoadingProgressView *progressView = [LXLoadingProgressView progressView];
        progressView.bounds = CGRectMake(0.0, 0.0, 80.0, 80.0);
        progressView.center = self.center;
        [self addSubview:progressView];
        _progressView = progressView;
    }
    
    self.progress = kLoadingProgressBeginValue;
}
- (void)setProgress:(float)progress
{
    _progress = progress;
    if (_progressView) {
        _progressView.progress = _progress;
    }
}
- (void)removeProgressView
{
    [self.progressView removeFromSuperview];
}
- (void)removeFailureLabel
{
    [self.failureLabel removeFromSuperview];
    [self removeFromSuperview];
}
- (void)showFailure
{
    [self performSelector:@selector(removeProgressView) withObject:Nil afterDelay:0.5];
    UILabel *label = [[UILabel alloc]init];
    label.bounds = CGRectMake(0.0, 0.0, self.bounds.size.width, 20.0);
    label.center = self.center;
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor lightGrayColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:[UIFont systemFontOfSize:18.0]];
    
    label.text = @"网络不给力，图片加载失败!";
    
    [self addSubview:label];
    self.failureLabel = label;
    
    [self performSelector:@selector(removeFailureLabel) withObject:Nil afterDelay:3.0];
}

@end
