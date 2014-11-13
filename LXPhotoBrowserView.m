//
//
//  Created by xinliu on 14-8-13.
//  Copyright (c) 2014年 xinliu. All rights reserved.
//

#import "LXPhotoBrowserView.h"
#import "LXPhotoBrowserModel.h"
#import "UIImageView+WebCache.h"
#import "LXLoadingView.h"

@interface LXPhotoBrowserView ()
{
    BOOL _singleTap;
    BOOL _doubleTap;
    CGPoint _imgZoomCenter;
}

@property (weak,nonatomic) LXLoadingView *loadingView;
@end

@implementation LXPhotoBrowserView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        UIImageView *imgView = [[UIImageView alloc]init];
        [self addSubview:imgView];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView = imgView;
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
        singleTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTap];
    }
    return self;
}
#pragma mark - Tap
- (void)doubleTap:(UITapGestureRecognizer *)recognizer
{
    _doubleTap = YES;
    if (self.isLoading || !_photoModel.image) return;
    
    self.userInteractionEnabled = NO;
    
    if (self.zoomScale == self.maximumZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:YES];
        _imgView.center = _imgZoomCenter;
    }
    else{
        _imgZoomCenter = _imgView.center;
        
        CGPoint tapPoint = [recognizer locationInView:self];
        
        CGRect rect;
        rect.size.width = self.bounds.size.width / self.maximumZoomScale;
        rect.size.height = self.bounds.size.height / self.maximumZoomScale;
        rect.origin.x = tapPoint.x - (rect.size.width/2.0);
        rect.origin.y = tapPoint.y - (rect.size.height/2.0);
        [self zoomToRect:rect animated:YES];
        
        CGFloat contentH = self.contentSize.height;
        CGFloat contentW = self.contentSize.width;
        CGFloat viewH = self.bounds.size.height;
        CGFloat viewW = self.bounds.size.width;
        
        CGFloat H = MAX(contentH, viewH);
        CGFloat W = MAX(contentW, viewW);
        
        _imgView.center = CGPointMake(W/2.0, H/2.0);
    }
    
    self.userInteractionEnabled = YES;
}
- (void)singleTap:(UITapGestureRecognizer *)recognizer
{
    _doubleTap = NO;
    [self performSelector:@selector(handleSingleTap) withObject:Nil afterDelay:0.25];

}
- (void)handleSingleTap
{
    if (_doubleTap) return;
    self.userInteractionEnabled = NO;
    if ([self.delegate respondsToSelector:@selector(photoBrowserViewDidExit:)]) {
        [self.delegate photoBrowserViewDidExit:self];
    }
}
#pragma mark - private method
- (void)setPhotoModel:(LXPhotoBrowserModel *)photoModel
{
    _photoModel = photoModel;
    
    if (_photoModel.image) {
        [_imgView setImage:_photoModel.image];
    }
    else{
        [_imgView setImage:_photoModel.placeHolder];
    }
    [self adjustFrame];
}
- (void)loadImageWithProgressView
{
    if (self.isLoading || _photoModel.image) return;
    self.isLoading = YES;
    
    LXLoadingView *loadingV = [LXLoadingView loadingView];
    [self addSubview:loadingV];
    self.loadingView = loadingV;
    self.loadingView.center = CGPointMake(self.bounds.size.width/2.0,self.bounds.size.height/2.0);
    [loadingV showLoading];
    
    __weak LXPhotoBrowserView *pView = self;
    __weak LXLoadingView *loadingView = loadingV;
    
    [_imgView setImageWithURL:[NSURL URLWithString:_photoModel.urlString] placeholderImage:_photoModel.placeHolder options:SDWebImageRetryFailed|SDWebImageDownloaderLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        if (receivedSize > 0.0 && loadingView && pView) {
            float progress = (float)receivedSize/expectedSize;
            loadingView.progress = progress;
        }
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        if (!error) {
            [loadingView removeFromSuperview];
            
            pView.photoModel.image = image;
            [pView adjustFrame];
        }
        else{
            [loadingView showFailure];
        }
        pView.isLoading = NO;
    }];
}
- (void)adjustFrame
{
    if (!_imgView.image) return;
    
    CGFloat viewW = self.bounds.size.width;
    CGFloat viewH = self.bounds.size.height;
    CGFloat imgW =  _imgView.image.size.width;
    CGFloat imgH = _imgView.image.size.height;
    
    self.maximumZoomScale = 2.0;
    self.minimumZoomScale = 1.0;
    self.zoomScale = 1.0;
    
    if (!_photoModel.image) {
        CGFloat scale = viewW / imgW;
        imgW = viewW;
        imgH = viewH / scale;
    }
    
    CGFloat delta = viewW/imgW;
    if (delta<1.0) {
        imgW = viewW;
        imgH = imgH*delta;
    }
    
    CGRect tempFrame = CGRectMake(0, 0, imgW, imgH);
    tempFrame.origin.x = (viewW-imgW)/2.0;
    if (imgH<viewH) {
        tempFrame.origin.y = (viewH-imgH)/2.0;
    }
    self.contentSize = tempFrame.size;
    
    if (self.isAnimation && [self.delegate respondsToSelector:@selector(photoBrowserView:animationShowWithFrame:)]) {
        [self.delegate photoBrowserView:self animationShowWithFrame:tempFrame];
        self.isAnimation = NO;
    }
    else{
        _imgView.frame = tempFrame;
        self.contentOffset = CGPointZero;
    }
}
- (void)setCanLoading:(BOOL)canLoading
{
    _canLoading = canLoading;
    if (canLoading && !self.isLoading && !_photoModel.image) {
        [self loadImageWithProgressView];
    }
}
- (void)cleanup
{
    [_loadingView removeFromSuperview];
    [_imgView cancelCurrentImageLoad];
}
- (void)dealloc
{
    [self cleanup];
}
@end
