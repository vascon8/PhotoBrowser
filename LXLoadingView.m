//
//
//  Created by xinliu on 14-10-19.
//  Copyright (c) 2014年 xinliu. All rights reserved.
//

#import "LXLoadingView.h"
#import "LXLoadingProgressView.h"

@interface LXLoadingView ()

@property (weak,nonatomic) LXLoadingProgressView *progressView;

@end

@implementation LXLoadingView
- (id)init
{
    if(self = [super init]){
        self.frame = [UIScreen mainScreen].applicationFrame;
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
        LXLoadingProgressView *progrssView = [LXLoadingProgressView progressView];
        progrssView.bounds = CGRectMake(0.0, 0.0, 80.0, 80.0);
        progrssView.center = self.center;
        self.progressView = progrssView;
        [self addSubview:progrssView];
    }
    _progressView.progress = kLoadingProgressBeginValue;
}
- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    _progressView.progress = progress;
    if (progress >= 1.0) {
        [self.progressView removeFromSuperview];
    }
}
@end
