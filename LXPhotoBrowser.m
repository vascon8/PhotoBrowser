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
    
    NSInteger _visibleDictCapacity;
    NSInteger _reuseableSetCapacity;
}

@property (weak,nonatomic) LXPhotoBrowserView       *zoomView;

@end

@implementation LXPhotoBrowser
#pragma mark - lifecycle
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:(51.0 / 255.0) alpha:1.0];
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
    
    CGRect frame = self.bounds;
    frame.size.width -= 2*kLXPhotoViewPagePadding;
    frame.origin.x = kLXPhotoViewPagePadding;
    
    pView.frame = frame;
    pView.isAnimation = YES;
    pView.photoModel = _photoList[0];
    pView.canLoading = YES;
}
- (void)showPhotoAtPage:(NSInteger)pageNo withAnimation:(BOOL)isAnimation
{
    [self loadPage:pageNo withAnimation:isAnimation adjustF:NO canLoading:YES];
    
    NSInteger prePage = pageNo-1;
    NSInteger nextPage = pageNo+1;
    if (prePage<0) prePage=0;
    if (nextPage>_photoList.count-1) nextPage = _photoList.count-1;
    if (prePage != pageNo) [self loadPage:prePage withAnimation:NO adjustF:YES canLoading:NO];
    if (nextPage != pageNo) [self loadPage:nextPage withAnimation:NO adjustF:YES canLoading:NO];
}
- (void)loadPage:(NSInteger)pageNo withAnimation:(BOOL)isAnimation adjustF:(BOOL)adjustF canLoading:(BOOL)canLoading
{
    LXPhotoBrowserView *pView = _visiblePhotoBrowserViewDict[@(pageNo)];
    if (!pView) {
        pView = [self dequeueReusablePhotoBrowserView];
        
        CGRect frame = self.bounds;
        frame.size.width -= 2*kLXPhotoViewPagePadding;
        frame.origin.x = self.bounds.size.width*pageNo + kLXPhotoViewPagePadding;
        
        pView.frame = frame;
        pView.isAnimation = isAnimation;
        pView.photoModel = _photoList[pageNo];
        
        [self addSubview:pView];
        [_visiblePhotoBrowserViewDict setObject:pView forKey:@(pageNo)];
        
    }
    else{
        if (adjustF && !canLoading) {
           [pView adjustFrame];
        }
    }
    pView.canLoading = canLoading;
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
            if (_reuseablePhotoBrowserViewSet.count < _reuseableSetCapacity) {
                [_reuseablePhotoBrowserViewSet addObject:pView];
            }
            
            [_visiblePhotoBrowserViewDict removeObjectForKey:key];
            [pView removeFromSuperview];
        }
    }];
    
    while (_reuseablePhotoBrowserViewSet.count > _reuseableSetCapacity) {
        LXPhotoBrowserView *pView = [_reuseablePhotoBrowserViewSet anyObject];
        [_reuseablePhotoBrowserViewSet removeObject:pView];
    }
}
#pragma mark - photoBrowserView delegate
- (void)photoBrowserView:(LXPhotoBrowserView *)photoBrowserView animationShowWithFrame:(CGRect)frame
{
    CGRect srcFrame = photoBrowserView.photoModel.srcFrame;
    photoBrowserView.imgView.frame = srcFrame;
    
    NSLog(@"%f %f",frame.size.height,photoBrowserView.bounds.size.height);
    if (frame.size.height > photoBrowserView.bounds.size.height) {
        photoBrowserView.imgView.frame = frame;
        photoBrowserView.photoModel.srcImageView.image = photoBrowserView.photoModel.placeHolder;
        return;
    }
    
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
    
    if (photoBrowserView.isLoading) {
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
        if ([self.delegate respondsToSelector:@selector(photoBrowserDidExit:)]) {
            [self.delegate photoBrowserDidExit:self];
        }
    }];
}
- (void)cleanup
{
    [_visiblePhotoBrowserViewDict enumerateKeysAndObjectsUsingBlock:^(id key, LXPhotoBrowserView *pView, BOOL *stop) {
        if (![key isEqualToValue:@(_currentIndex)]) {
            [pView cleanup];
            [pView removeFromSuperview];
            [_visiblePhotoBrowserViewDict removeObjectForKey:key];
        }
    }];
}
#pragma mark - private
- (void)setPhotoList:(NSArray *)photoList
{
    _photoList = photoList;
    NSInteger count = photoList.count;
    
    if (count > 1) {
        _visibleDictCapacity = (count>2) ? 3 : 2;
        _visiblePhotoBrowserViewDict = [NSMutableDictionary dictionaryWithCapacity:_visibleDictCapacity];
        
        if (count > 2) {
            _reuseableSetCapacity = 1;
            _reuseablePhotoBrowserViewSet = [NSMutableSet setWithCapacity:_reuseableSetCapacity];
        }
    }
    
    for (int i=0; i<photoList.count; i++) {
        LXPhotoBrowserModel *model = photoList[i];
        model.index = i;
    }
}
@end
