//
//  ViewController.h
//  Video Blurring
//
//  Created by Ray Wenderlich on 11/9/13.
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.
//

@import UIKit;

#import "DropDownMenuController.h"


@interface ViewController : UIViewController<DropDownMenuDelegate, UINavigationControllerDelegate,  UIImagePickerControllerDelegate>

-(IBAction)showButtonPressed;

@end
