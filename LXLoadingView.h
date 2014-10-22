//
//
//  Created by xinliu on 14-10-19.
//  Copyright (c) 2014年 xinliu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXLoadingView : UIView

+ (instancetype)loadingView;

@property (assign,nonatomic) CGFloat progress;
- (void)showLoading;

@end
