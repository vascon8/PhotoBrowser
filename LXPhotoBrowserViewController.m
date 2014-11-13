//
//
//  Created by xinliu on 14-8-13.
//  Copyright (c) 2014年 xinliu. All rights reserved.
//

#import "LXPhotoBrowserViewController.h"
#import "LXPhotoBrowser.h"
#import "LXPhotoBrowserToolBar.h"
#import "LXPhotoBrowserView.h"

#define kLXPhotoBrowserToolBarHeight 30.0

@interface LXPhotoBrowserViewController ()<UIScrollViewDelegate,LXPhotoBrowserDelegate>

@property (weak,nonatomic) LXPhotoBrowser                               *photoBrowser;
@property (weak,nonatomic) LXPhotoBrowserToolBar                        *toolBar;
@property (assign,nonatomic,getter = isPreviousStatusBarHidden) BOOL    previousStatusBarHidden;
@end

@implementation LXPhotoBrowserViewController
#pragma mark - lifecycle
-(void)loadView
{
    self.view = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.view.backgroundColor = [UIColor clearColor];
    [self hideStatusBar];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createPhotoBrowser];
    [self createToolBar];
}
- (void)createPhotoBrowser
{
    LXPhotoBrowser *photoBrowser = [[LXPhotoBrowser alloc]init];
    [self.view addSubview:photoBrowser];
    photoBrowser.delegate = self;
    self.photoBrowser = photoBrowser;
}
- (void)createToolBar
{
    LXPhotoBrowserToolBar *toolBar = [LXPhotoBrowserToolBar toolBar];
    [self.view addSubview:toolBar];
    self.toolBar = toolBar;
}
- (void)hideStatusBar
{
    _previousStatusBarHidden = [UIApplication sharedApplication].statusBarHidden;
    [UIApplication sharedApplication].statusBarHidden = YES;
}
- (void)restoreStatusBar
{
    [UIApplication sharedApplication].statusBarHidden = _previousStatusBarHidden;
}
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
#pragma mark - showPhotoBrowser
- (void)showPhotoBrowserWithPhotoList:(NSArray *)photoList photoIndex:(NSInteger)photoIndex
{
    CGRect photoBrowserF = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height-kLXPhotoBrowserToolBarHeight);
    self.photoBrowser.frame = CGRectInset(photoBrowserF, -kLXPhotoViewPagePadding, 0.0);
    
    self.photoBrowser.currentIndex = photoIndex;
    self.photoBrowser.photoList = photoList;
    
    NSInteger photoCount = photoList.count;
    if (photoCount == 1) {
        [self.photoBrowser showPhoto];
    }
    else if(photoCount >1){
        [self.photoBrowser showPhotoAtPage:photoIndex withAnimation:YES];
    }
    [self setupToolbar:photoIndex photoList:photoList];
    
    CGFloat W = self.photoBrowser.bounds.size.width;
    self.photoBrowser.contentSize = CGSizeMake(W*photoList.count, 0);
    self.photoBrowser.contentOffset = CGPointMake(photoIndex*W, 0);
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self.view];
    [keyWindow.rootViewController addChildViewController:self];
}
- (void)setupToolbar:(NSInteger)currentPage photoList:(NSArray *)photoList
{
    CGFloat W = self.view.bounds.size.width;
    CGFloat H = self.view.bounds.size.height;
    CGRect frame = CGRectMake(0.0, H-kLXPhotoBrowserToolBarHeight, W, kLXPhotoBrowserToolBarHeight);
    _toolBar.frame = frame;
    _toolBar.photoList = photoList;
    _toolBar.photoCount = photoList.count;
    _toolBar.currentPhotoIndex = currentPage;
}
#pragma mark - photoBrowser delegate
- (void)photoBrowserDidExit:(LXPhotoBrowser *)photoBrowser
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    
    if ([self.delegate respondsToSelector:@selector(photoBrowser:didEndAtIndex:)]) {
        [self.delegate photoBrowser:self.photoBrowser didEndAtIndex:photoBrowser.currentIndex];
    }
    
    [self restoreStatusBar];
}
- (void)photoBrowserBeforeExit:(LXPhotoBrowser *)photoBrowser
{
    [_toolBar removeFromSuperview];
    
    UIView *placeHolder = [[UIView alloc]init];
    placeHolder.backgroundColor = [UIColor whiteColor];
    LXPhotoBrowserModel *model = photoBrowser.photoList[photoBrowser.currentIndex];
    placeHolder.frame = model.srcFrame;
    [self.view insertSubview:placeHolder belowSubview:self.photoBrowser];
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
- (void)cleanup
{
    [self scrollViewDidEndDecelerating:self.photoBrowser];
}
- (void)didReceiveMemoryWarning
{
    [self.photoBrowser cleanup];
    [self cleanup];
    [super didReceiveMemoryWarning];
}
#pragma mark - rotate
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{

}

@end
