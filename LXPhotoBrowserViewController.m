//
//
//  Created by xinliu on 14-8-13.
//  Copyright (c) 2014年 xinliu. All rights reserved.
//

#import "LXPhotoBrowserViewController.h"
#import "LXPhotoBrowser.h"
#import "LXPhotoBrowserToolBar.h"
#import "LXPhotoBrowserView.h"

@interface LXPhotoBrowserViewController ()<UIScrollViewDelegate,LXPhotoBrowserDelegate>

@property (weak,nonatomic) LXPhotoBrowser                       *photoBrowser;
@property (weak,nonatomic) LXPhotoBrowserToolBar                *toolBar;
@property (assign,nonatomic,getter = isShowStatusBar) BOOL      showStatusBar;

@property (weak,nonatomic) UIView                               *originView;
@end

@implementation LXPhotoBrowserViewController
#pragma mark - load view
-(void)loadView
{
    _showStatusBar = [UIApplication sharedApplication].statusBarHidden;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    self.view = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    LXPhotoBrowser *photoBrowser = [[LXPhotoBrowser alloc]init];
    [self.view addSubview:photoBrowser];
    photoBrowser.delegate = self;
    self.photoBrowser = photoBrowser;
}
#pragma mark - toolbar
- (void)setupToolbar:(NSInteger)currentPage photoCount:(NSInteger)photoCount
{
    LXPhotoBrowserToolBar *toolBar = [LXPhotoBrowserToolBar toolBar];
    [self.view addSubview:toolBar];
    self.toolBar = toolBar;
    
    CGFloat W = self.view.bounds.size.width;
    CGFloat H = self.view.bounds.size.height;
    CGFloat toolBarH = 30.0;
    CGRect frame = CGRectMake(0.0, H-toolBarH, W, toolBarH);
    toolBar.frame = frame;
    toolBar.photoCount = photoCount;
    toolBar.currentPhotoIndex = currentPage;
}

#pragma mark - showPhotoBrowser
- (void)showPhotoBrowserInRect:(CGRect)rect withPhotoList:(NSArray *)photoList photoIndex:(NSInteger)photoIndex originView:(UIView *)originView
{
    self.view.frame = rect;
    CGFloat toolBarH = 30.0;
    self.photoBrowser.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height-toolBarH);
    
    self.photoBrowser.backgroundColor = [UIColor blackColor];
    self.photoBrowser.currentIndex = photoIndex;
    self.photoBrowser.photoList = photoList;
    
    NSInteger photoCount = photoList.count;
    if (photoCount == 1) {
        [self.photoBrowser showPhoto];
    }
    else if(photoCount >1){
        [self.photoBrowser showPhotoAtPage:photoIndex withAnimation:YES];
    }
    [self setupToolbar:photoIndex photoCount:photoCount];
    _toolBar.photoList = photoList;
    _toolBar.currentPhotoIndex = photoIndex;
    
    CGFloat W = rect.size.width;
    self.photoBrowser.contentSize = CGSizeMake(W*photoList.count, 0);
    self.photoBrowser.contentOffset = CGPointMake(photoIndex*W, 0);
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self.view];
    [keyWindow.rootViewController addChildViewController:self];
    
    self.originView = originView;
}
#pragma mark - photoBrowser delegate
- (void)photoBrowserDidExit:(LXPhotoBrowser *)photoBrowser
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    [UIApplication sharedApplication].statusBarHidden = _showStatusBar;
    
    if ([self.delegate respondsToSelector:@selector(photoBrowser:didEndAtIndex:)]) {
        [self.delegate photoBrowser:self.photoBrowser didEndAtIndex:photoBrowser.currentIndex];
    }
}
- (void)photoBrowserBeforeExit:(LXPhotoBrowser *)photoBrowser
{
    [_toolBar removeFromSuperview];
}
#pragma mark - scrollView delegate
- (void)scrollViewDidScroll:(LXPhotoBrowser *)photoBrowser
{
    CGFloat W = photoBrowser.bounds.size.width;
    CGFloat offsetX = photoBrowser.contentOffset.x;
    
    CGFloat floatV = offsetX / W;
    _toolBar.currentPhotoIndex = floatV+0.5;
    
    CGFloat delta = fabsf(offsetX - photoBrowser.currentIndex * W);
    if (delta < W)    return;
    
    NSInteger currentPage = offsetX / W;
    [self.photoBrowser showPhotoAtPage:currentPage withAnimation:NO];
}
- (void)scrollViewDidEndDecelerating:(LXPhotoBrowser *)photoBrowser
{
    NSInteger currentPage = photoBrowser.contentOffset.x/photoBrowser.frame.size.width;
    [photoBrowser enqueueReuseablePhotoBrowserViewWithCurrengPage:currentPage];
}
#pragma mark - private
- (void)setOriginScrollView:(UIScrollView *)originScrollView
{
    if (_originScrollView && [_originScrollView isMemberOfClass:[UIScrollView class]] && self.originView) {
        [_originScrollView scrollRectToVisible:self.originView.frame animated:YES];
    }
}
#pragma mark - rotate
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{

}

@end
