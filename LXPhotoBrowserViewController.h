//
//
//  Created by xinliu on 14-8-13.
//  Copyright (c) 2014年 xinliu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXPhotoBrowserModel.h"

@class LXPhotoBrowserView;
@class LXPhotoBrowser;

@protocol LXPhotoBrowserViewControllerDelegate <NSObject>
@optional
- (void)photoBrowser:(LXPhotoBrowser *)photoBrowser didEndAtIndex:(NSInteger)index;

@end

@interface LXPhotoBrowserViewController : UIViewController

@property (weak,nonatomic) id<LXPhotoBrowserViewControllerDelegate>delegate;

- (void)showPhotoBrowserInRect:(CGRect)rect withPhotoList:(NSArray *)photoList photoIndex:(NSInteger)photoIndex;

@end
