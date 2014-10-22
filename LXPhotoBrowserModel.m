
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
- (UIImage *)placeHolder
{
    return self.srcImageView.image;
}

@end
