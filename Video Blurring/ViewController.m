//
//  ViewController.m
//  Video Blurring
//
//  Created by Ray Wenderlich on 11/9/13.
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.
//

@import MobileCoreServices;
#import <GPUImage/GPUImage.h>

#import "ViewController.h"
#import "BlurView.h"

@interface ViewController (){
    IBOutlet UIButton *_menuButton;
    DropDownMenuController *_dropDownMenuController;
    
    GPUImageView *_backgroundImageView;
    GPUImageMovie *_recordedVideo;
    
    GPUImageVideoCamera *_liveVideo;
    
    GPUImageMovieWriter *_movieWriter;
    
    BlurView *_recordView;
    UIButton *_recordButton;
    BOOL _recording;
    
    BlurView *_controlView;
    UIButton *_controlButton;
    BOOL _playing;
    
    BOOL _isVideoLive;
    
    UITapGestureRecognizer *_tap;
    GPUImageiOSBlurFilter *_blurFilter;
    GPUImageBuffer *_videoBuffer;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _blurFilter = [[GPUImageiOSBlurFilter alloc] init];

    _videoBuffer = [[GPUImageBuffer alloc] init];
    [_videoBuffer setBufferSize:1];

    _backgroundImageView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width)];
    [self.view insertSubview:_backgroundImageView atIndex:0];
    
    _dropDownMenuController = [[DropDownMenuController alloc] init];
    _dropDownMenuController.delegate = self;
    
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(prepareToHideInterface)];
    [self.view addGestureRecognizer:_tap];
    
    _recordView = [[BlurView alloc] initWithFrame:CGRectMake(self.view.frame.size.height/2 - 50, 250, 110, 60)];
//    _recordView.backgroundColor = [UIColor grayColor];

    _recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _recordButton.frame = CGRectMake(5, 5, 100, 50);
    [_recordButton setTitle:@"Record" forState:UIControlStateNormal];
    [_recordButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_recordButton setImage:[UIImage imageNamed:@"RecordDot.png"] forState:UIControlStateNormal] ;
    [_recordButton addTarget:self action:@selector(recordVideo) forControlEvents:UIControlEventTouchUpInside];
    
    [_recordView addSubview:_recordButton];
    _recording = NO;
 
    _recordView.hidden = YES;
    [self.view addSubview:_recordView];
    
    
    _controlView = [[BlurView alloc] initWithFrame:CGRectMake(self.view.frame.size.height/2 - 40, 230, 80, 80)];
//    _controlView.backgroundColor = [UIColor grayColor];

    _controlButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _controlButton.frame = CGRectMake(0, 0, 80, 80);
    [_controlButton setImage:[UIImage imageNamed:@"PlayButton.png"] forState:UIControlStateNormal] ;
    [_controlButton addTarget:self action:@selector(toggleVideo) forControlEvents:UIControlEventTouchUpInside];
    
    [_controlView addSubview:_controlButton];
    
    _controlView.hidden = YES;
    [self.view addSubview:_controlView];
    
    [self useLiveCamera];
    
    
}

-(IBAction)showButtonPressed{
    if(_playing){
        [self toggleVideo];
    }
    [_liveVideo pauseCameraCapture];
    
    [_dropDownMenuController show];
}

/*
 This method is called when the user selects an item from the drop down menu
 */
-(void)didSelectItemAtIndex:(NSInteger)index{
    if(index == 0){
        [self useLiveCamera];
    }
    else if(index == 1){
        [self pickVideoFromSaved];
    }
}

-(void)didHideMenu{
    [_liveVideo resumeCameraCapture];

//    [_liveVideo addTarget:_videoBuffer];
//    [_videoBuffer addTarget:_blurFilter];
//    [_blurFilter addTarget:_recordView];
}


-(void)pickVideoFromSaved{
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    pickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    pickerController.mediaTypes = @[(NSString*)kUTTypeMovie];
    [self presentViewController:pickerController animated:YES completion:nil];
}


-(void)useLiveCamera{
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No camera detected" message:@"The current device does not have a camera to record from." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    _liveVideo = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
    _liveVideo.outputImageOrientation = UIInterfaceOrientationLandscapeLeft;
    
//    [_liveVideo addTarget:_backgroundImageView];
    [_liveVideo addTarget:_videoBuffer];
    [_videoBuffer addTarget:_backgroundImageView];
    [_videoBuffer addTarget:_blurFilter];
    [_blurFilter addTarget:_recordView];

    [_liveVideo startCameraCapture];

    _recordView.hidden = NO;
    _controlView.hidden = YES;
    
}


/*
 This method is called after the user picks a video from their shared videos
 */
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSURL *movieURL = [info objectForKey:UIImagePickerControllerMediaURL];
    
    [self loadVideowithURL:movieURL];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)loadVideowithURL:(NSURL*)url{
    [_liveVideo removeAllTargets];
    _recordedVideo = [[GPUImageMovie alloc] initWithURL:url];
    _recordedVideo.shouldRepeat = YES;
    _recordedVideo.playAtActualSpeed = YES;

    [_recordedVideo addTarget:_videoBuffer];
    [_videoBuffer addTarget:_backgroundImageView];
    [_videoBuffer addTarget:_blurFilter];
    [_blurFilter addTarget:_recordView];

//    [_recordedVideo addTarget:_backgroundImageView];

    _recordView.hidden = YES;
    _controlView.hidden = NO;
    
}

-(void)recordVideo{
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    
    if(!_recording){
        unlink([path UTF8String]);
        
        _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:[NSURL fileURLWithPath:path] size:_backgroundImageView.frame.size];
        [_liveVideo addTarget:_movieWriter];
        [_movieWriter startRecording];
        
        [_recordButton setImage:[UIImage imageNamed:@"RecordStop.png"] forState:UIControlStateNormal] ;
        [_recordButton setTitle:@"Stop" forState:UIControlStateNormal];
        

        _menuButton.hidden = YES;
        _recording = YES;

        
    }
    else{
        [_movieWriter finishRecording];
        UISaveVideoAtPathToSavedPhotosAlbum(path, nil, nil, nil);
        
        [_recordButton setImage:[UIImage imageNamed:@"RecordDot.png"] forState:UIControlStateNormal] ;
        [_recordButton setTitle:@"Record" forState:UIControlStateNormal];
        [self loadVideowithURL:[NSURL fileURLWithPath:path]];
        
        _menuButton.hidden = NO;
        _recording = NO;


    }
}


/*
 This method starts and stops the current video
 */
-(void)toggleVideo{
    if (!_playing) {
        [_recordedVideo startProcessing];
        [_controlButton setImage:[UIImage imageNamed:@"StopButton.png"] forState:UIControlStateNormal];
        _playing = YES;
        [self prepareToHideInterface];
    }
    else{
        [_recordedVideo endProcessing];
        [_controlButton setImage:[UIImage imageNamed:@"PlayButton.png"] forState:UIControlStateNormal];
        _playing = NO;
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
}

/*
 This method starts the timer to fade out the interface while a video is playing
 */
-(void)prepareToHideInterface{
    [self showInterface];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if(_playing){
        [self performSelector:@selector(hideInterface) withObject:nil afterDelay:2.0f];
    }
}

-(void)hideInterface{
    [UIView animateWithDuration:1.0f animations:^{
        _controlView.alpha = 0.0f;
        _menuButton.alpha = 0.0f;
    }];

}

-(void)showInterface{
    _controlView.alpha = 1.0f;
    _menuButton.alpha = 1.0f;
}




-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL) shouldAutorotate {
    return YES;
}


- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeLeft;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    _liveVideo.outputImageOrientation = toInterfaceOrientation;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}



@end
