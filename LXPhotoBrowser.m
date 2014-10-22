//
//  LXPhotoBrowser.m
//  0926新浪微博
//
//  Created by xinliu on 14-10-19.
//  Copyright (c) 2014年 xinliu. All rights reserved.
//

#import "LXPhotoBrowser.h"
#import "LXPhotoBrowserView.h"
#import "LXPhotoBrowserModel.h"

@interface LXPhotoBrowser () <LXPhotoBrowserViewDelegate,UIScrollViewDelegate>

@property (strong,nonatomic) NSMutableDictionary    *visiblePhotoBrowserViewDict;
@property (strong,nonatomic) NSMutableSet           *reuseablePhotoBrowserViewSet;

@end

@implementation LXPhotoBrowser

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.showsVerticalScrollIndicator = NO;
        self.pagingEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}
#pragma mark -exit PhotoBrowser
- (void)tap:(UITapGestureRecognizer *)recognizer
{
    LXPhotoBrowserView *pView = self.visiblePhotoBrowserViewDict[@(_currentIndex)];
    
    if (pView.isLoading) {
        [self removeFromSuperview];
        if ([self.delegate respondsToSelector:@selector(photoBrowserDidExit:)]) {
            [self.delegate photoBrowserDidExit:self];
        }
        return;
    }

    [UIView animateWithDuration:0.4f animations:^{
        [pView.imgView setFrame:pView.photoModel.srcFrame];
        [pView setBackgroundColor:[UIColor clearColor]];
        [self setBackgroundColor:[UIColor clearColor]];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if ([self.delegate respondsToSelector:@selector(photoBrowserDidExit:)]) {
            [self.delegate photoBrowserDidExit:self];
        }
    }];
}
#pragma mark - show photo
- (void)showPhotoAtPage:(NSInteger)pageNo withAnimation:(BOOL)isAnimation
{
    LXPhotoBrowserView *pView = self.visiblePhotoBrowserViewDict[@(pageNo)];
    if (!pView) {
        pView = [self dequeueReusablePhotoBrowserView];
        [self addSubview:pView];
        [self.visiblePhotoBrowserViewDict setObject:pView forKey:@(pageNo)];
        
        CGFloat W = self.bounds.size.width;
        CGFloat H = self.bounds.size.height;
        CGRect frame = CGRectMake(W*pageNo, 0, W, H);
        pView.frame = frame;
        pView.isAnimation = isAnimation;
        pView.photoModel = _photoList[pageNo];
    }
}
#pragma mark - reuse photoBrowserView
- (LXPhotoBrowserView *)dequeueReusablePhotoBrowserView
{
    LXPhotoBrowserView *pView = [self.reuseablePhotoBrowserViewSet anyObject];
    if (!pView) {
        pView = [[LXPhotoBrowserView alloc]init];
        pView.delegate = self;
    }
    else{
        [self.reuseablePhotoBrowserViewSet removeObject:pView];
    }
    return pView;
}
- (void)enqueueReuseablePhotoBrowserViewWithCurrengPage:(NSInteger)currentPage
{
    _currentIndex = currentPage;
    
    [_visiblePhotoBrowserViewDict enumerateKeysAndObjectsUsingBlock:^(id key,LXPhotoBrowserView *pView, BOOL *stop) {
        if (![key isEqualToValue:@(currentPage)]) {
            [self.reuseablePhotoBrowserViewSet addObject:pView];
            [self.visiblePhotoBrowserViewDict removeObjectForKey:key];
            [pView removeFromSuperview];
        }
    }];
}
#pragma mark - photoBrowserView delegate
- (void)photoBrowserView:(LXPhotoBrowserView *)photoBrowserView animationShowWithFrame:(CGRect)frame
{
    CGRect srcFrame = photoBrowserView.photoModel.srcFrame;
    photoBrowserView.imgView.frame = srcFrame;
    [self setBackgroundColor:[UIColor clearColor]];
    
    [UIView animateWithDuration:0.4f animations:^{
        photoBrowserView.imgView.frame = frame;
        [self setBackgroundColor:[UIColor lightGrayColor]];
    }];
}
#pragma mark - private
- (NSMutableDictionary *)visiblePhotoBrowserViewDict
{
    if (!_visiblePhotoBrowserViewDict) {
        _visiblePhotoBrowserViewDict = [NSMutableDictionary dictionary];
    }
    return _visiblePhotoBrowserViewDict;
}
- (NSMutableSet *)reuseablePhotoBrowserViewSet
{
    if (!_reuseablePhotoBrowserViewSet) {
        _reuseablePhotoBrowserViewSet = [NSMutableSet set];
    }
    return _reuseablePhotoBrowserViewSet;
}

@end
