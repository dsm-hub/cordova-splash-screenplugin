//
//  StartAnimation.m
//  iDubaiIDubaiIphone
//
//  Created by Kris Tian on 15/5/12.
//
//


#import "ibiVideo.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>

@interface ibiVideo ()
{
    AVPlayerViewController *playerViewController;
}
@end

@implementation ibiVideo: UIViewController

-(void)play:(CDVInvokedUrlCommand*)command{

    [self performSelector:@selector(videoPlay:) withObject:nil afterDelay:0.3f];
}


- (void)videoPlay:(id)sender{
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    
    NSString *defaultDBPath = [[NSBundle mainBundle] pathForResource:@"start_animation" ofType:@"mp4"];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        defaultDBPath = [[NSBundle mainBundle] pathForResource:@"start_animation" ofType:@"mp4"];
    }
    
    if ([fileManager fileExistsAtPath:defaultDBPath]){
        
        UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
        playerViewController = [[AVPlayerViewController alloc] init];
              NSURL *movieURL=[NSURL fileURLWithPath:defaultDBPath];
             playerViewController.player = [AVPlayer playerWithURL:movieURL];
              
       
        [playerViewController.view setFrame:window.bounds];
        
        [self presentViewController:playerViewController animated:YES completion:nil
        ];
         playerViewController.showsPlaybackControls = false;
            
              playerViewController.videoGravity=AVLayerVideoGravityResizeAspectFill;
                 
              [playerViewController.player play];
                
              [window addSubview:playerViewController.view];
              
        [window addSubview:playerViewController.view];
        
        CGFloat duration = [self getVideoDuration:defaultDBPath];
        [self performSelector:@selector(videoFinished:) withObject:nil afterDelay:duration+4.0f];
    }
    
}


-(CGFloat)getVideoDuration:(NSString *)path {
    NSURL *movieURL=[NSURL fileURLWithPath:path];
    
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:movieURL options:opts]; // 初始化视频媒体文件
    CGFloat second = 0;
    second = urlAsset.duration.value *1.0/ urlAsset.duration.timescale; // 获取视频总时长,单位秒
    NSLog(@"movie duration : %f", second);
    return second;
}

- (void)videoFinished:(NSNotification*)notification {
    NSLog(@"结束");
    
//    [UIView animateWithDuration:0.0f animations:^{
////        playerViewController.view.alpha = 0 ;
//    } completion:^(BOOL finished) {
        [playerViewController.view removeFromSuperview];
//    }];
}

@end
