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
    LXLoadingView *_loadingView;
}
@end

@implementation LXPhotoBrowserView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *imgView = [[UIImageView alloc]init];
        [self addSubview:imgView];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        _imgView = imgView;
        
        _loadingView = [LXLoadingView loadingView];
        
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
    }
    return self;
}
#pragma mark - private method
- (void)setPhotoModel:(LXPhotoBrowserModel *)photoModel
{
    _photoModel = photoModel;
    
    if (_photoModel.image) {
        [_imgView setImage:_photoModel.image];
        [self adjustFrame];
    }
    else{
        [_loadingView showLoading];
        [self addSubview:_loadingView];
        self.isLoading = YES;
        
        __unsafe_unretained LXPhotoBrowserView *pView = self;
        [_imgView setImageWithURL:[NSURL URLWithString:_photoModel.urlString] placeholderImage:_photoModel.placeHolder options:SDWebImageCacheMemoryOnly|SDWebImageProgressiveDownload progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            _loadingView.progress = (float)receivedSize/expectedSize;
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            [_loadingView removeFromSuperview];
            
            pView.photoModel.image = image;
            pView.isLoading = NO;
            [pView adjustFrame];
        }];
    }
}
- (void)adjustFrame
{
    CGFloat viewW = self.frame.size.width;
    CGFloat viewH = self.frame.size.height;
    CGFloat imgW = _imgView.image.size.width;
    CGFloat imgH = _imgView.image.size.height;
    CGFloat delta = viewW/imgW;

    if (delta<1.0) {
        imgW = viewW;
        imgH = imgH*delta;
    }
    
    
    CGRect tempFrame = CGRectMake(0, 0, imgW, imgH);
    tempFrame.origin.x = (viewW-imgW)/2;
    if (imgH<viewH) {
        tempFrame.origin.y = (viewH-imgH)/2;
    }
    else
    {
        self.contentSize = CGSizeMake(viewW, imgH);
    }
    
    if (self.isAnimation && [self.delegate respondsToSelector:@selector(photoBrowserView:animationShowWithFrame:)]) {
        [self.delegate photoBrowserView:self animationShowWithFrame:tempFrame];
    }
    else{
        _imgView.frame = tempFrame;
    }
}
@end
