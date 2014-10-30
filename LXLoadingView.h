//
//
//  Created by xinliu on 14-10-19.
//  Copyright (c) 2014年 xinliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LXLoadingProgressView;

@interface LXLoadingView : UIView

+ (instancetype)loadingView;

@property (nonatomic) float progress;

- (void)showLoading;
- (void)showFailure;

@end
