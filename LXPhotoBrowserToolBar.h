//
//
//  Created by xinliu on 14-10-28.
//  Copyright (c) 2014年 xinliu. All rights reserved.
//

#import <UIKit/UIKit.h>

//typedef void (^SaveImage)(NSInteger index);

@interface LXPhotoBrowserToolBar : UIView

@property (assign,nonatomic) NSInteger photoCount;
@property (assign,nonatomic) NSInteger currentPhotoIndex;

@property (weak,nonatomic) UILabel      *toolBarLabel;
@property (weak,nonatomic) UIButton     *saveButton;
@property (strong,nonatomic) NSArray    *photoList;

+ (instancetype)toolBar;

@end
