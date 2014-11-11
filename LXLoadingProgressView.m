//
//
//  Created by xinliu on 14-10-19.
//  Copyright (c) 2014年 xinliu. All rights reserved.
//

#import "LXLoadingProgressView.h"

#define kDegreeToRadian(x) (M_PI/180.0 * (x))

@interface LXLoadingProgressView ()

@end

@implementation LXLoadingProgressView
- (id)init
{
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        self.progress = 0.0;
    }
    return self;
}
+ (instancetype)progressView
{
    return [[self alloc]init];
}
#pragma mark - update progress
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat W = rect.size.width;
    CGFloat H = rect.size.height;
    CGFloat bigRadius = MIN(W, H) / 2.0;
    CGFloat smallRadius = 0.8 * bigRadius;
    CGFloat pathWidth = 0.2 * bigRadius;
    CGPoint center = CGPointMake(W/2.0, H/2.0);
    
    CGFloat radians = kDegreeToRadian((_progress*360.0)-90);
    CGFloat progressX = bigRadius*(1 + 0.9*cosf(radians));
    CGFloat progressY = bigRadius*(1 + 0.9*sinf(radians));
    
    [self.progressViewColor setFill];
    CGContextAddArc(context, center.x, center.y, bigRadius, 0, 2*M_PI, NO);
    CGContextFillPath(context);
    
    [self.trackColor setFill];
    CGContextMoveToPoint(context, center.x, center.y);
    CGContextAddArc(context, center.x, center.y, bigRadius, -M_PI_2, radians, NO);
    CGContextFillPath(context);
    
    [self.trackPointColor setFill];
    CGContextAddArc(context, center.x, center.y, pathWidth, M_2_PI, -M_2_PI, NO);
    CGContextFillPath(context);
    
    [self.trackColor setFill];
    CGContextAddEllipseInRect(context, CGRectMake(progressX - pathWidth/2, progressY - pathWidth/2, pathWidth, pathWidth));
    CGContextFillPath(context);
        
    CGContextSetBlendMode(context, kCGBlendModeClear);
    CGContextAddEllipseInRect(context, CGRectMake(center.x-smallRadius, center.y-smallRadius, smallRadius*2.0, smallRadius*2.0));
	CGContextFillPath(context);
}
#pragma mark - private
- (UIColor *)progressViewColor
{
    if (!_progressViewColor) {
        _progressViewColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    }
    return _progressViewColor;
}
- (UIColor *)trackColor
{
    if (!_trackColor) {
        _trackColor = [UIColor colorWithRed:208.0 green:230.0 blue:196.0 alpha:1.0];
    }
    return _trackColor;
}
- (UIColor *)trackPointColor
{
    if (!_trackPointColor) {
        _trackPointColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.9];
    }
    return _trackPointColor;
}
- (void)setProgress:(float)progress
{
    if (progress >= 1.0) progress = 0.9;
    _progress = progress;
    [self setNeedsDisplay];
}

@end
