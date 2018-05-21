//
//  LocalVideoPlayerViewController.m
//  ZSTest
//
//  Created by Bjmsp on 2017/11/21.
//  Copyright © 2017年 zhoushuai. All rights reserved.
//

#import "TestAVPlayerViewController.h"
//第一步:引用AVFoundation框架
#import <AVFoundation/AVFoundation.h>

@interface TestAVPlayerViewController ()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic,strong)AVPlayer *player;//播放器对象
@property (nonatomic,strong)AVPlayerItem *currentPlayerItem;

@property (weak, nonatomic) IBOutlet UIButton *playerInfoButton;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;

//播放进度
@property (weak, nonatomic) IBOutlet UISlider *sliderView;
@property (weak, nonatomic) IBOutlet UILabel *currentPlayTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalNeedPlayTimeLabel;

//缓冲进度
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *currentLoadTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalNeedLoadTimeLabel;

//加载Loading提示
@property(nonatomic,strong)UIActivityIndicatorView *activityInDicatorView;

@end

@implementation TestAVPlayerViewController
#pragma mark - 控制器视图方法
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    //第二步:获取播放地址URL
    //本地视频路径
    NSString* localFilePath=[[NSBundle mainBundle]pathForResource:@"不能说的秘密" ofType:@"mp4"];
    NSURL *localVideoUrl = [NSURL fileURLWithPath:localFilePath];
    //网络视频路径
    NSString *webVideoPath = @"http://data.vod.itc.cn/?rb=1&key=jbZhEJhlqlUN-Wj_HEI8BjaVqKNFvDrn&prod=flash&pt=1&new=/137/113/vITnGttPQmaeWrZ3mg1j9H.mp4";
    NSURL *webVideoUrl = [NSURL URLWithString:webVideoPath];
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:webVideoUrl];
    self.currentPlayerItem = playerItem;
   
    //第三步:创建播放器(四种方法)
    //URL创建的方式会默认为AVPlayer创建一个AVPlayerItem
    //self.player = [AVPlayer playerWithURL:localVideoUrl];
    //self.player = [[AVPlayer alloc] initWithURL:localVideoUrl];
    //self.player = [AVPlayer playerWithPlayerItem:playerItem];
    self.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    
    //第四步:创建显示视频的AVPlayerLayer,设置视频显示属性
    /*
     AVLayerVideoGravityResizeAspectFill等比例铺满，宽或高有可能出屏幕
     AVLayerVideoGravityResizeAspect 等比例  默认
     AVLayerVideoGravityResize 完全适应宽高
     */
    AVPlayerLayer *avLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    avLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    //第五步：添加视频图层
    avLayer.frame = _containerView.bounds;
    [_containerView.layer addSublayer:avLayer];
    
    //第六步：执行play方法，开始播放
    //本地视频可以直接播放
    //网络视频需要监测AVPlayerItem的status属性为AVPlayerStatusReadyToPlay时方法才会生效
    [self.player play];
    
    //测试1：注册观察者，监测播放器属性
    //观察Status属性，可以在加载成功之后得到视频的长度
    [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //观察loadedTimeRanges，可以获取缓存进度，实现缓冲进度条
    [self.player.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    //测试2:刷新播放进度
    __weak __typeof(self) weakSelf = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        //当前播放的时间
        NSTimeInterval currentTime = CMTimeGetSeconds(time);
        //视频的总时间
        NSTimeInterval totalTime = CMTimeGetSeconds(weakSelf.player.currentItem.duration);
        //设置滑块的当前进度
        weakSelf.sliderView.value = currentTime/totalTime;
        //设置显示的时间：以00:00:00的格式
        weakSelf.currentPlayTimeLabel.text = [weakSelf formatTimeWithTimeInterVal:currentTime];
    }];
    //开始加载视频
    self.sliderView.enabled = NO;
    [self showaAtivityInDicatorView:YES];
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.player pause];
    _player = nil;
}

- (void)dealloc{
    [self.currentPlayerItem removeObserver:self forKeyPath:@"status"];
    [self.currentPlayerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}



#pragma mark - 观察者方法
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        //获取playerItem的status属性最新的状态
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue];
        switch (status) {
            case AVPlayerStatusReadyToPlay:{
                CMTime duration = playerItem.duration; //获取视频长度
                //更新显示:视频总时长:
                self.totalNeedPlayTimeLabel.text = [self formatTimeWithTimeInterVal:CMTimeGetSeconds(duration)];
                //开启滑块的滑动功能
                self.sliderView.enabled = YES;
                //关闭加载Loading提示
                [self showaAtivityInDicatorView:NO];
                //开始播放视频
                [self.player play];
                break;
            }
            case AVPlayerStatusFailed:{//视频加载失败，点击重新加载
                [self showaAtivityInDicatorView:NO];//关闭Loading视图
                self.playerInfoButton.hidden = NO; //显示错误提示按钮，点击后重新加载视频
                [self.playerInfoButton setTitle:@"资源加载失败，点击继续尝试加载" forState: UIControlStateNormal];
                break;
            }
            case AVPlayerStatusUnknown:{
                NSLog(@"加载遇到未知问题:AVPlayerStatusUnknown");
                break;
            }
            default:
                break;
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        //获取视频缓冲进度数组，这些缓冲的数组可能不是连续的
        NSArray *loadedTimeRanges = playerItem.loadedTimeRanges;
        //获取最新的缓冲区间
        CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
        //缓冲区间的开始的时间
        NSTimeInterval loadStartSeconds = CMTimeGetSeconds(timeRange.start);
        //缓冲区间的时长
        NSTimeInterval loadDurationSeconds = CMTimeGetSeconds(timeRange.duration);
        //当前视频缓冲时间总长度
        NSTimeInterval currentLoadTotalTime = loadStartSeconds + loadDurationSeconds;
        //NSLog(@"开始缓冲:%f,缓冲时长:%f,总时间:%f", loadStartSeconds, loadDurationSeconds, currentLoadTotalTime);
        //更新显示：当前缓冲总时长
        _currentLoadTimeLabel.text = [self formatTimeWithTimeInterVal:currentLoadTotalTime];
        //更新显示：视频的总时长
        _totalNeedLoadTimeLabel.text = [self formatTimeWithTimeInterVal:CMTimeGetSeconds(self.player.currentItem.duration)];
        //更新显示：缓冲进度条的值
        _progressView.progress = currentLoadTotalTime/CMTimeGetSeconds(self.player.currentItem.duration);
    }
}


#pragma mark - 事件响应处理
//播放失败，点击重新加载
- (IBAction)playerInfoBtnClick:(id)sender {
    //在这里处理播放失败逻辑
}
//UISlider的响应方法:拖动滑块，改变播放进度
- (IBAction)sliderViewChange:(id)sender {
    if(self.player.status == AVPlayerStatusReadyToPlay){
        NSTimeInterval playTime = self.sliderView.value * CMTimeGetSeconds(self.player.currentItem.duration);
        CMTime seekTime = CMTimeMake(playTime, 1);
        [self.player seekToTime:seekTime completionHandler:^(BOOL finished) {
        }];
    }
}



#pragma mark - 辅助方法
//转换时间格式
- (NSString *)formatTimeWithTimeInterVal:(NSTimeInterval)timeInterVal{
    int minute = 0, hour = 0, secend = timeInterVal;
    minute = (secend % 3600)/60;
    hour = secend / 3600;
    secend = secend % 60;
    return [NSString stringWithFormat:@"%02d:%02d:%02d", hour, minute, secend];
}



#pragma mark - 加载Loading图
- (UIActivityIndicatorView *)activityInDicatorView{
    if (_activityInDicatorView == nil) {
        _activityInDicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityInDicatorView.frame = CGRectMake((kDeviceWidth - 20 -100)/2, 100, 100, 100);
    }
    return _activityInDicatorView;
}

- (void)showaAtivityInDicatorView:(BOOL)show{
    if(show){
        [self.containerView addSubview:self.activityInDicatorView];
        [self.activityInDicatorView startAnimating];
    }else{
        [self.activityInDicatorView stopAnimating];
        [self.activityInDicatorView removeFromSuperview];
    }
}


 @end




