//
//  TestViewController.m
//  Test
//
//  Created by zhoushuai on 16/3/7.
//  Copyright © 2016年 zhoushuai. All rights reserved.
//

#import "TestViewController.h"
#import "TestMPMoviePlayerController.h"
#import "TestAVPlayerViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
@interface TestViewController ()

@property (weak, nonatomic) IBOutlet UIButton *removeBtn;


@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.title = @"测试";
 }

- (IBAction)TestPlayerBtnClick:(UIButton *)sender {
    switch (sender.tag - 100) {
        case 1:{
            TestMPMoviePlayerController *testMPPlayerController = [[TestMPMoviePlayerController alloc] init];
            [self.navigationController pushViewController:testMPPlayerController animated:YES];
            break;
        }
        case 2:{//MPMoviePlayerViewController:播放本地视频路径
            //第一步:获取视频路径
            //本地视频
            NSString* localFilePath=[[NSBundle mainBundle]pathForResource:@"不能说的秘密" ofType:@"mp4"];
            NSURL *localVideoUrl = [NSURL fileURLWithPath:localFilePath];
            //在线视频
            //NSString *webVideoPath = @"http://api.junqingguanchashi.net/yunpan/bd/c.php?vid=/junqing/1115.mp4";
            //NSURL *webVideoUrl = [NSURL URLWithString:webVideoPath];
            //第二步:创建视频播放器
            MPMoviePlayerViewController *playerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:localVideoUrl];
            //第三步:设置播放器属性
            //通过moviePlayer属性设置播放器属性(与MPMoviePlayerController类似)
            playerViewController.moviePlayer.scalingMode = MPMovieScalingModeFill;
            //第四步:跳转视频播放界面
            [self presentViewController:playerViewController animated:YES completion:nil];

            break;
        }
        case 3:{//MPMoviePlayerViewController:播放网络视频路径
            NSString *webVideoPath = @"http://data.vod.itc.cn/?rb=1&key=jbZhEJhlqlUN-Wj_HEI8BjaVqKNFvDrn&prod=flash&pt=1&new=/137/113/vITnGttPQmaeWrZ3mg1j9H.mp4";
            NSURL *webVideoUrl = [NSURL URLWithString:webVideoPath];
            MPMoviePlayerViewController *playerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:webVideoUrl];
            [self presentViewController:playerViewController animated:YES completion:nil];

            break;
        }
            
        case 4:{//测试AVPlayer的使用
            TestAVPlayerViewController *testAVPlayerVC = [[TestAVPlayerViewController alloc] initWithNibName:@"TestAVPlayerViewController" bundle:nil];
            [self.navigationController pushViewController:testAVPlayerVC animated:YES];
            break;
        }
        case 5:{//AVPlayerViewController:方法1-模态弹出
            //步骤1：获取视频路径
            NSString *webVideoPath = @"http://data.vod.itc.cn/?rb=1&key=jbZhEJhlqlUN-Wj_HEI8BjaVqKNFvDrn&prod=flash&pt=1&new=/137/113/vITnGttPQmaeWrZ3mg1j9H.mp4";
            NSURL *webVideoUrl = [NSURL URLWithString:webVideoPath];
            //步骤2：创建AVPlayer
            AVPlayer *avPlayer = [[AVPlayer alloc] initWithURL:webVideoUrl];
            //步骤3：使用AVPlayer创建AVPlayerViewController，并跳转播放界面
            AVPlayerViewController *avPlayerVC =[[AVPlayerViewController alloc] init];
            avPlayerVC.player = avPlayer;
            [self presentViewController:avPlayerVC animated:YES completion:nil];
            break;
        }
        case 6:{//AVPlayerViewController:方法2-添加播放View
            //与播放逻辑无关的判断代码，用于显示和隐藏移除按钮
            self.removeBtn.hidden = NO;
            UIView *playerView = [self.view viewWithTag:100];
            if (playerView) {
                return;
            }
            
            //步骤1：获取视频路径
            NSString *webVideoPath = @"http://data.vod.itc.cn/?rb=1&key=jbZhEJhlqlUN-Wj_HEI8BjaVqKNFvDrn&prod=flash&pt=1&new=/137/113/vITnGttPQmaeWrZ3mg1j9H.mp4";
            NSURL *webVideoUrl = [NSURL URLWithString:webVideoPath];
            //步骤2：创建AVPlayer
            AVPlayer *avPlayer = [[AVPlayer alloc] initWithURL:webVideoUrl];
            //步骤3：使用AVPlayer创建AVPlayerViewController，并跳转播放界面
            AVPlayerViewController *avPlayerVC =[[AVPlayerViewController alloc] init];
            avPlayerVC.player = avPlayer;
            //步骤4：设置播放器视图大小
            avPlayerVC.view.frame = CGRectMake(0, 0, kDeviceWidth, kDeviceWidth);
            avPlayerVC.view.tag = 100;
            //特别注意:AVPlayerViewController不能作为局部变量被释放，否则无法播放成功
            //解决1.AVPlayerViewController作为属性
            //解决2:使用addChildViewController，AVPlayerViewController作为子视图控制器
            [self addChildViewController:avPlayerVC];
            [self.view addSubview:avPlayerVC.view];
            break;
        }
     
        default:
            break;
    }
}


- (IBAction)removePlayerView:(id)sender {
    //移除AVPlayerViewController
    NSMutableArray *childVCs = [self.childViewControllers copy];
    for (int i = 0; i< childVCs.count; i++) {
        UIViewController *vc = childVCs[i];
        if ([vc isKindOfClass:[AVPlayerViewController class]]) {
            AVPlayerViewController *avPlayerVC = (AVPlayerViewController *)vc;
            [avPlayerVC.player pause];
            avPlayerVC.player = nil;
            [vc removeFromParentViewController];
        }
    }
    
    //隐藏用于移除的按钮
    UIView *playerView = [self.view viewWithTag:100];
    [playerView removeFromSuperview];
    self.removeBtn.hidden = YES;
}



 
@end
