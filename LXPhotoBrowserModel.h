
//  Created by xinliu on 14-8-13.
//  Copyright (c) 2014年 xinliu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LXPhotoBrowserModel : NSObject
//source
@property (copy,nonatomic) NSString *urlString;
@property (strong,nonatomic) UIImageView *srcImageView;

//download image
@property (strong,nonatomic) UIImage *image;
@property (assign,nonatomic) NSInteger index;
@property (strong,nonatomic) UIImage *placeHolder;
@property (strong,nonatomic) UIImage *capture;

@property (assign,nonatomic) BOOL   save;

+ (instancetype)photoBrowserModelWithDict:(NSDictionary *)dict;
- (CGRect)srcFrame;

@end
