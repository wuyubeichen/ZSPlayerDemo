//
//  TestMPMoviePlayerController.m
//  ZSTest
//
//  Created by Bjmsp on 2017/12/19.
//  Copyright © 2017年 zhoushuai. All rights reserved.
//

#import "TestMPMoviePlayerController.h"
//第一步:引用MediaPlayer框架，声明视图控制器属性PlayerController
//使用MPMoviePlayerController需要引入MediaPlayer.framework，并且用于播放的MPMoviewPlayerController对象必须被当前控制器持有，否则无法实现播放。
#import <MediaPlayer/MediaPlayer.h>
@interface TestMPMoviePlayerController ()

@property(nonatomic,strong)MPMoviePlayerController *playerController;

@property(nonatomic,strong)UIButton *captureBtn;       //截屏按钮
@property(nonatomic,strong)UIImageView *captureImgView;//截屏显示图片
@end

@implementation TestMPMoviePlayerController

#pragma mark - 视图生命周期及控件加载
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //第二步：获取视频路径，创建播放器
    //本地视频路径
    NSString* localFilePath=[[NSBundle mainBundle]pathForResource:@"不能说的秘密" ofType:@"mp4"];
    NSURL *localVideoUrl = [NSURL fileURLWithPath:localFilePath];
    //网络视频路径
    NSString *webVideoPath = @"http://data.vod.itc.cn/?rb=1&key=jbZhEJhlqlUN-Wj_HEI8BjaVqKNFvDrn&prod=flash&pt=1&new=/137/113/vITnGttPQmaeWrZ3mg1j9H.mp4";
    NSURL *webVideoUrl = [NSURL URLWithString:webVideoPath];
    //self.playerController =[[MPMoviePlayerController alloc]initWithContentURL:localVideoUrl];
    self.playerController =[[MPMoviePlayerController alloc]initWithContentURL:webVideoUrl];

    
    //第三步：设置Frame将播放器View添加到视图控制器View上
    self.playerController.view.frame = CGRectMake(0, 10, kDeviceWidth, 300);
    [self.view addSubview: self.playerController.view];
    
    //第四步：设置播放器属性
    //设置控制面板风格:无，嵌入，全屏，默认
    self.playerController.controlStyle = MPMovieControlStyleDefault;
    //设置是否自动播放(默认为YES）
    self.playerController.shouldAutoplay = NO;
    //设置播放器显示模式，类似于图片的处理，设置Fill有可能造成部分区域被裁剪
    self.playerController.scalingMode = MPMovieScalingModeAspectFit;
    //设置重复模式
    self.playerController.repeatMode = MPMovieRepeatModeOne;
    
    //第五步：播放视频
    //播放前的准备，会中断当前正在活跃的音频会话
    [ self.playerController  prepareToPlay];
    //播放视频，设置了自动播放之后可以不调用此方法
    //[ self.playerController  play];
    
    //其他操作：
    //1.关于通知的使用(还有很多通知可以监听，可查看SDK)
    NSNotificationCenter *notificaionCenter = [NSNotificationCenter defaultCenter];
    //监听播放器状态的变化
    [notificaionCenter addObserver:self
                          selector:@selector(playerStateChanged:)
                              name:MPMoviePlayerPlaybackStateDidChangeNotification
                            object:nil];
    //监听播放完成
    [notificaionCenter addObserver:self
                          selector:@selector(playerFinished) name:MPMoviePlayerPlaybackDidFinishNotification
                            object:nil];
    //监听切换到全屏
    [notificaionCenter addObserver:self
                          selector:@selector(palyerChangeFullScreen) name:MPMoviePlayerDidEnterFullscreenNotification
                            object:nil];
    //监听截屏操作完成
    [notificaionCenter addObserver:self
                          selector:@selector(playerCaptureFinished:) name:MPMoviePlayerThumbnailImageRequestDidFinishNotification
                            object:nil];
    
    //2.测试截屏操作
    //添加一个按钮测试截屏
    _captureBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(self.playerController.view.frame) + 30, kDeviceWidth - 30 * 2, 50)];
    _captureBtn.backgroundColor = [UIColor purpleColor];
    [_captureBtn setTitle:@"截图当前屏幕" forState: UIControlStateNormal];
    [_captureBtn addTarget:self action:@selector(captureCurrentScreenImg) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_captureBtn];
    //添加一个ImgView 显示截屏后的图片
    _captureImgView = [[UIImageView alloc] initWithFrame:CGRectMake((kDeviceWidth - 150)/2, CGRectGetMaxY(_captureBtn.frame) + 20, 150, 150)];
    _captureImgView.contentMode = UIViewContentModeScaleAspectFit;
    _captureImgView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_captureImgView];
}

//第六步：关闭播放器
- (void)dealloc{
    //当前视图控制器pop之后并不会关闭播放，需要手动关闭
    [self.playerController stop];
    self.playerController = nil;
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - 监听通知
//播放状态变化
//注意：播放状态改变，注意播放完成时的状态是暂停
- (void)playerStateChanged:(NSNotification *)notificaion{
    switch (self.playerController.playbackState) {
        case MPMoviePlaybackStateStopped:{
            NSLog(@"播放停止");
            break;
        }
        case MPMoviePlaybackStatePlaying:{
            NSLog(@"播放器正在播放");
            break;
        }
        case MPMoviePlaybackStatePaused:{
            NSLog(@"播放器暂停");
            break;
        }
        case MPMoviePlaybackStateInterrupted:{
            NSLog(@"播放器中断");
            break;
        }
        case MPMoviePlaybackStateSeekingForward:{
            NSLog(@"播放器快进");
            break;
        }
        case MPMoviePlaybackStateSeekingBackward:{
            NSLog(@"播放器快退");
            break;
        }
        default:
            break;
    }
}

//视频播放结束
- (void)playerFinished{
    NSLog(@"playerFinished：播放结束");
}

//播放器切换到了全屏
- (void)palyerChangeFullScreen{
    NSLog(@"palyerChangeFullScreen：播放器进入全屏");
}

//播放器截屏结束
- (void)playerCaptureFinished:(NSNotification *)notification{
    NSLog(@"playerCaptureFinished：播放器截屏结束");
    //获取并显示截图
    UIImage *image=notification.userInfo[MPMoviePlayerThumbnailImageKey];
    self.captureImgView.image = image;
}

#pragma mark - 截屏幕方法
- (void)captureCurrentScreenImg{
    //截取当前屏幕
    [self.playerController requestThumbnailImagesAtTimes:@[@(self.playerController.currentPlaybackTime)] timeOption:MPMovieTimeOptionNearestKeyFrame];
}

@end


