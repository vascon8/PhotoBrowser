
//
//  Created by xinliu on 14-8-13.
//  Copyright (c) 2014年 xinliu. All rights reserved.
//

#import "LXPhotoBrowserModel.h"

@implementation LXPhotoBrowserModel
+ (instancetype)photoBrowserModelWithDict:(NSDictionary *)dict
{
    LXPhotoBrowserModel *p = [[LXPhotoBrowserModel alloc]init];
    [p setValuesForKeysWithDictionary:dict];
    return p;
}
- (CGRect)srcFrame
{
    return [self.srcImageView convertRect:self.srcImageView.bounds toView:Nil];
}

- (UIImage *)capture:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *capture = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return capture;
}
- (void)setSrcImageView:(UIImageView *)srcImageView
{
    _srcImageView = srcImageView;
    _placeHolder = srcImageView.image;
    if (srcImageView.clipsToBounds) {
       _capture = [self capture:srcImageView];
    }
}

@end
