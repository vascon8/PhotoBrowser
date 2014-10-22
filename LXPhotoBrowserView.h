//
//
//  Created by xinliu on 14-8-13.
//  Copyright (c) 2014年 xinliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LXPhotoBrowserView;
@class LXPhotoBrowserModel;

@protocol LXPhotoBrowserViewDelegate <NSObject>

- (void)photoBrowserView:(LXPhotoBrowserView *)photoBrowserView animationShowWithFrame:(CGRect)frame;

@end

@interface LXPhotoBrowserView : UIScrollView

@property (strong,nonatomic) LXPhotoBrowserModel *photoModel;
@property (strong,nonatomic) UIImageView *imgView;
@property (assign,nonatomic) BOOL isAnimation;
@property (assign,nonatomic) BOOL isLoading;
@property (weak,nonatomic)id<LXPhotoBrowserViewDelegate,UIScrollViewDelegate>delegate;

@end
