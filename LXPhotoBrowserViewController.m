//
//
//  Created by xinliu on 14-8-13.
//  Copyright (c) 2014年 xinliu. All rights reserved.
//

#import "LXPhotoBrowserViewController.h"
#import "LXPhotoBrowser.h"
#import "LXPhotoBrowserToolBar.h"

@interface LXPhotoBrowserViewController ()<UIScrollViewDelegate,LXPhotoBrowserDelegate>

@property (weak,nonatomic) LXPhotoBrowser                       *photoBrowser;
@property (weak,nonatomic) LXPhotoBrowserToolBar                *toolBar;
@property (assign,nonatomic,getter = isShowStatusBar) BOOL      showStatusBar;

@property (weak,nonatomic) UIView                               *originView;
//@property (assign,nonatomic) NSInteger              photoCount;
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
    CGRect frame = CGRectMake(0.0, H-40.0, W, 30.0);
    toolBar.frame = frame;
    toolBar.photoCount = photoCount;
    toolBar.currentPhotoIndex = currentPage;
}

#pragma mark - showPhotoBrowser
- (void)showPhotoBrowserInRect:(CGRect)rect withPhotoList:(NSArray *)photoList photoIndex:(NSInteger)photoIndex originView:(UIView *)originView
{
    self.view.frame = rect;
    self.photoBrowser.frame = self.view.bounds;
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
    
    _toolBar.currentPhotoIndex = currentPage;
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
