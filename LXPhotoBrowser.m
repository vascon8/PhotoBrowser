//
//
//  Created by xinliu on 14-10-19.
//  Copyright (c) 2014年 xinliu. All rights reserved.
//

#import "LXPhotoBrowser.h"
#import "LXPhotoBrowserView.h"
#import "LXPhotoBrowserModel.h"
@interface LXPhotoBrowser () <LXPhotoBrowserViewDelegate,UIScrollViewDelegate>

{
    NSMutableDictionary *_visiblePhotoBrowserViewDict;
    NSMutableSet        *_reuseablePhotoBrowserViewSet;
}

@property (weak,nonatomic) LXPhotoBrowserView       *zoomView;

@end

@implementation LXPhotoBrowser

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.showsVerticalScrollIndicator = NO;
        self.pagingEnabled = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    }
    return self;
}
#pragma mark - show photo
- (void)showPhoto
{
    LXPhotoBrowserView *pView = [[LXPhotoBrowserView alloc]init];
    pView.delegate = self;
    [self addSubview:pView];
    self.zoomView = pView;
    _currentIndex = 0;
    
    CGFloat W = self.bounds.size.width;
    CGFloat H = self.bounds.size.height;
    CGRect frame = CGRectMake(0.0, 0.0, W, H);
    pView.frame = frame;
    pView.isAnimation = YES;
    pView.photoModel = _photoList[0];
}
- (void)loadPage:(NSInteger)pageNo withAnimation:(BOOL)isAnimation adjustF:(BOOL)adjustF
{
    LXPhotoBrowserView *pView = _visiblePhotoBrowserViewDict[@(pageNo)];
    if (!pView) {
        pView = [self dequeueReusablePhotoBrowserView];
        
        CGFloat W = self.bounds.size.width;
        CGFloat H = self.bounds.size.height;
        CGRect frame = CGRectMake(W*pageNo, 0.0, W, H);
        pView.frame = frame;
        pView.isAnimation = isAnimation;
        pView.photoModel = _photoList[pageNo];
        
        [self addSubview:pView];
        [_visiblePhotoBrowserViewDict setObject:pView forKey:@(pageNo)];
    }
    else{
        if (adjustF) {
           [pView adjustFrame];
        }
    }
}
- (void)showPhotoAtPage:(NSInteger)pageNo withAnimation:(BOOL)isAnimation
{
    [self loadPage:pageNo withAnimation:isAnimation adjustF:NO];
    
    NSInteger prePage = pageNo-1;
    NSInteger nextPage = pageNo+1;
    if (prePage<0) prePage=0;
    if (nextPage>_photoList.count-1) nextPage = _photoList.count-1;
    if (prePage != pageNo) [self loadPage:prePage withAnimation:NO adjustF:YES];
    if (nextPage != pageNo) [self loadPage:nextPage withAnimation:NO adjustF:YES];
}
#pragma mark - reuse photoBrowserView
- (LXPhotoBrowserView *)dequeueReusablePhotoBrowserView
{
    LXPhotoBrowserView *pView = [_reuseablePhotoBrowserViewSet anyObject];
    if (!pView) {
        pView = [[LXPhotoBrowserView alloc]init];
        pView.delegate = self;
    }
    else{
        [_reuseablePhotoBrowserViewSet removeObject:pView];
    }
    return pView;
}

- (void)enqueueReuseablePhotoBrowserViewWithCurrengPage:(NSInteger)currentPage
{
    if (currentPage == _currentIndex) return;
    _currentIndex = currentPage;
    
    NSInteger nextPage = currentPage+1;
    NSInteger prePage = currentPage-1;
    if (nextPage>_photoList.count-1)    nextPage = _photoList.count-1;
    if (prePage<0)  prePage = 0;
    
    [_visiblePhotoBrowserViewDict enumerateKeysAndObjectsUsingBlock:^(id key,LXPhotoBrowserView *pView, BOOL *stop) {
        if (![key isEqualToValue:@(currentPage)] && ![key isEqualToValue:@(prePage)] && ![key isEqualToValue:@(nextPage)]){
                [_reuseablePhotoBrowserViewSet addObject:pView];
                [_visiblePhotoBrowserViewDict removeObjectForKey:key];
                [pView removeFromSuperview];
        }
    }];
    
    while (_reuseablePhotoBrowserViewSet.count>2) {
        LXPhotoBrowserView *pView = [_reuseablePhotoBrowserViewSet anyObject];
        [_reuseablePhotoBrowserViewSet removeObject:pView];
    }
}
#pragma mark - photoBrowserView delegate
- (void)photoBrowserView:(LXPhotoBrowserView *)photoBrowserView animationShowWithFrame:(CGRect)frame
{
    CGRect srcFrame = photoBrowserView.photoModel.srcFrame;
    photoBrowserView.imgView.frame = srcFrame;
    
    [UIView animateWithDuration:kPhotoBrowserViewAniShowDur animations:^{
        photoBrowserView.imgView.frame = frame;
    } completion:^(BOOL finished) {
        photoBrowserView.photoModel.srcImageView.image = photoBrowserView.photoModel.placeHolder;
    }];
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (_photoList.count == 1) {
        return _zoomView.imgView;
    }
    else{
        LXPhotoBrowserView *pView = _visiblePhotoBrowserViewDict[@(_currentIndex)];
        return pView.imgView;
    }
}
- (void)photoBrowserViewDidExit:(LXPhotoBrowserView *)photoBrowserView
{
    if ([self.delegate respondsToSelector:@selector(photoBrowserBeforeExit:)]) {
        [self.delegate photoBrowserBeforeExit:self];
    }
    [photoBrowserView.loadingView removeFromSuperview];
    
    if (photoBrowserView.isLoading) {
        [photoBrowserView removeFromSuperview];
        [self removeFromSuperview];
        if ([self.delegate respondsToSelector:@selector(photoBrowserDidExit:)]) {
            [self.delegate photoBrowserDidExit:self];
        }
        return;
    }
    
    [photoBrowserView.imgView setContentMode:photoBrowserView.photoModel.srcImageView.contentMode];
    photoBrowserView.imgView.clipsToBounds = photoBrowserView.photoModel.srcImageView.clipsToBounds;
    
    [UIView animateWithDuration:kPhotoBrowserViewAniExitDur animations:^{
        [photoBrowserView.imgView setImage:photoBrowserView.photoModel.srcImageView.image];
        [photoBrowserView.imgView setFrame:[photoBrowserView.photoModel.srcImageView convertRect:photoBrowserView.photoModel.srcImageView.bounds toView:photoBrowserView]];
        [self setBackgroundColor:[UIColor clearColor]];
    } completion:^(BOOL finished) {
        [photoBrowserView removeFromSuperview];
        [self removeFromSuperview];
        if ([self.delegate respondsToSelector:@selector(photoBrowserDidExit:)]) {
            [self.delegate photoBrowserDidExit:self];
        }
    }];
}

#pragma mark - private
- (void)setPhotoList:(NSArray *)photoList
{
    _photoList = photoList;
    
    if (photoList.count > 1) {
        _visiblePhotoBrowserViewDict = [NSMutableDictionary dictionaryWithCapacity:2];
        _reuseablePhotoBrowserViewSet = [NSMutableSet setWithCapacity:1];
    }
    
    for (int i=0; i<photoList.count; i++) {
        LXPhotoBrowserModel *model = photoList[i];
        model.index = i;
    }
}
@end
