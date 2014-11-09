//
//
//  Created by xinliu on 14-8-13.
//  Copyright (c) 2014年 xinliu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXLoadingView.h"

@class LXPhotoBrowserView;
@class LXPhotoBrowserModel;

#define kPhotoBrowserViewAniShowDur 0.3f
#define kPhotoBrowserViewAniExitDur 0.3f

@protocol LXPhotoBrowserViewDelegate <NSObject>

- (void)photoBrowserView:(LXPhotoBrowserView *)photoBrowserView animationShowWithFrame:(CGRect)frame;
- (void)photoBrowserViewDidExit:(LXPhotoBrowserView *)photoBrowserView;

@end

@interface LXPhotoBrowserView : UIScrollView

@property (strong,nonatomic) LXPhotoBrowserModel *photoModel;
@property (weak,nonatomic) UIImageView *imgView;
@property (assign,nonatomic) BOOL isAnimation;
@property (assign,nonatomic) BOOL isLoading;
@property (weak,nonatomic) LXLoadingView *loadingView;

@property (weak,nonatomic)id<LXPhotoBrowserViewDelegate,UIScrollViewDelegate>delegate;
- (void)adjustFrame;

@end
