//
//
//  Created by xinliu on 14-10-19.
//  Copyright (c) 2014年 xinliu. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kLoadingProgressBeginValue 0.000001

@interface LXLoadingProgressView : UIView

@property (strong,nonatomic) UIColor *progressViewColor;
@property (strong,nonatomic) UIColor *trackColor;
@property (strong,nonatomic) UIColor *trackPointColor;
@property (nonatomic) float progress;

+ (instancetype)progressView;

@end
