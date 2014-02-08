//
//  DropDownMenuController.h
//  Video Blurring
//
//  Created by Ray Wenderlich on 11/9/13.
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.
//

@import UIKit;

@protocol DropDownMenuDelegate <NSObject>

@required
-(void)didSelectItemAtIndex:(NSInteger)index;
-(void)didHideMenu;

@end

@interface DropDownMenuController : UIViewController


@property(nonatomic, weak) id<DropDownMenuDelegate> delegate;


- (void)show;


@end
