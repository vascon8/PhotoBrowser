//
//
//  Created by xinliu on 14-8-13.
//  Copyright (c) 2014年 xinliu. All rights reserved.
//

#import "LXPhotoBrowserViewController.h"
#import "LXPhotoBrowser.h"

@interface LXPhotoBrowserViewController ()<UIScrollViewDelegate,LXPhotoBrowserDelegate>

@property (weak,nonatomic) LXPhotoBrowser *photoBrowser;

@end

@implementation LXPhotoBrowserViewController
#pragma mark - load view
-(void)loadView
{
    LXPhotoBrowser *photoBrowser = [[LXPhotoBrowser alloc]init];
    self.view = photoBrowser;
    photoBrowser.delegate = self;
    self.photoBrowser = photoBrowser;
}
#pragma mark - showPhotoBrowser
- (void)showPhotoBrowserInRect:(CGRect)rect withPhotoList:(NSArray *)photoList photoIndex:(NSInteger)photoIndex
{
    self.view.frame = rect;
    self.photoBrowser.photoList = photoList;
    self.photoBrowser.currentIndex = photoIndex;
    [self.photoBrowser showPhotoAtPage:photoIndex withAnimation:YES];
    
    CGFloat W = rect.size.width;
    self.photoBrowser.contentSize = CGSizeMake(W*photoList.count, 0);
    self.photoBrowser.contentOffset = CGPointMake(photoIndex*W, 0);
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self.view];
    [keyWindow.rootViewController addChildViewController:self];
}
#pragma mark - photoBrowser delegate
- (void)photoBrowserDidExit:(LXPhotoBrowser *)photoBrowser
{
    [self removeFromParentViewController];
    if ([self.delegate respondsToSelector:@selector(photoBrowser:didEndAtIndex:)]) {
        [self.delegate photoBrowser:self.photoBrowser didEndAtIndex:photoBrowser.currentIndex];
    }
}
#pragma mark - scrollView delegate
- (void)scrollViewDidScroll:(LXPhotoBrowser *)photoBrowser
{
    NSInteger currentPage = photoBrowser.contentOffset.x/photoBrowser.frame.size.width;
    NSInteger nextPage = currentPage+1;
    if (nextPage > photoBrowser.photoList.count-1) {
        nextPage = photoBrowser.photoList.count-1;
    }
    if (currentPage<0) {
        currentPage=0;
    }
    for (NSInteger i=currentPage; i<=nextPage; i++) {
            [self.photoBrowser showPhotoAtPage:i withAnimation:NO];
    }
}
- (void)scrollViewDidEndDecelerating:(LXPhotoBrowser *)photoBrowser
{
    NSInteger currentPage = photoBrowser.contentOffset.x/photoBrowser.frame.size.width;
    
    [photoBrowser enqueueReuseablePhotoBrowserViewWithCurrengPage:currentPage];
}
#pragma mark - rotate
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
 
}

@end
