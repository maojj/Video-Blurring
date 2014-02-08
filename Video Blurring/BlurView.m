//
//  BlurView.m
//  Video Blurring
//
//  Created by maojj on 14-2-8.
//  Copyright (c) 2014年 Mike Jaoudi. All rights reserved.
//

#import "BlurView.h"

@implementation BlurView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect deviceSize = [UIScreen mainScreen].bounds;
        self.layer.contentsRect = CGRectMake(frame.origin.x/deviceSize.size.height,
                                             frame.origin.y/deviceSize.size.width,
                                             frame.size.width/deviceSize.size.height,
                                             frame.size.height/deviceSize.size.width);
        self.fillMode = kGPUImageFillModeStretch;
    }
    return self;
}

@end
