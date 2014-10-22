//
//
//  Created by xinliu on 14-10-19.
//  Copyright (c) 2014年 xinliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LXPhotoBrowser;

@protocol LXPhotoBrowserDelegate <NSObject>

- (void)photoBrowserDidExit:(LXPhotoBrowser *)photoBrowser;

@end

@interface LXPhotoBrowser : UIScrollView

@property (strong,nonatomic) NSArray *photoList;
@property (assign,nonatomic) NSInteger currentIndex;
@property (weak,nonatomic) id<LXPhotoBrowserDelegate,UIScrollViewDelegate>delegate;

- (void)showPhotoAtPage:(NSInteger)pageNo withAnimation:(BOOL)isAnimation;
- (void)enqueueReuseablePhotoBrowserViewWithCurrengPage:(NSInteger)currentPage;

@end