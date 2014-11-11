//
//
//  Created by xinliu on 14-10-28.
//  Copyright (c) 2014年 xinliu. All rights reserved.
//

#import "LXPhotoBrowserToolBar.h"
#import "LXPhotoBrowserModel.h"
#import "MBProgressHUD+MJ.h"

@interface LXPhotoBrowserToolBar ()
@end

@implementation LXPhotoBrowserToolBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.backgroundColor =[UIColor blackColor];
        [self setupImageButton];
    }
    return self;
}
+ (instancetype)toolBar
{
    return [[self alloc]init];
}
- (void)setupImageButton
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:btn];
    self.saveButton = btn;
    
    [btn setImage:[UIImage imageNamed:@"LXPhotoBrowserToolBar.bundle/save_icon"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"LXPhotoBrowserToolBar.bundle/save_icon_highlighted"] forState:UIControlStateHighlighted];
    
    [btn addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
}
- (void)saveImage
{
    UIImage *image = self.photo.image;
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), Nil);
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        [MBProgressHUD showError:@"保存失败"];
    }
    else{
        [MBProgressHUD showSuccess:@"保存成功"];
        self.photo.save = YES;
        _saveButton.enabled = NO;
    }
}
- (void)setCurrentPhotoIndex:(NSInteger)currentPhotoIndex
{
    _currentPhotoIndex = currentPhotoIndex;
    
    self.toolBarLabel.text = [NSString stringWithFormat:@"%d / %d",_currentPhotoIndex+1,_photoCount];
    
    if (!self.photo.image || self.photo.save) {
        _saveButton.enabled = NO;
    }
    else{
        _saveButton.enabled = YES;
    }
}
- (void)setPhotoCount:(NSInteger)photoCount
{
    _photoCount = photoCount;
    
    if (_photoCount > 1) {
        UILabel *label = [[UILabel alloc]init];
        self.toolBarLabel = label;
        label.frame = self.bounds;
        [self addSubview:label];
        label.font = [UIFont systemFontOfSize:18.0];
        label.textColor = [UIColor lightGrayColor];
        label.textAlignment = NSTextAlignmentCenter;
    }
}
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.toolBarLabel.frame = self.bounds;
    self.saveButton.frame = CGRectMake(10.0, 0.0, self.bounds.size.height, self.bounds.size.height);
}
- (LXPhotoBrowserModel *)photo
{
    return _photoList[_currentPhotoIndex];
}
@end
