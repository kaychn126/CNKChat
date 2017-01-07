//
//  CNKAudioManager.m
//  CNKChat
//
//  Created by chenkai on 2016/11/17.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import "CNKAudioManager.h"
#import <AVFoundation/AVFoundation.h>
#import "CNKChatMessageModel.h"
#import "TCBlobDownload.h"

@interface CNKAudioManager()<AVAudioRecorderDelegate, AVAudioPlayerDelegate>{
    dispatch_source_t _timer;
}
@property(readwrite, nonatomic, strong) NSDictionary *recordSettings;
@property(readwrite, nonatomic, strong) AVAudioRecorder *recorder;
@property(nonatomic, strong) AVAudioPlayer *player;
@property(nonatomic, copy) NSString *playingAudioCacheKey;
@property(nonatomic, assign) double recordInterval;

@property(nonatomic, copy) void(^recordCompletionBlock)(NSURL *audioContentOfUrl);
@property(nonatomic, copy) void(^playCompletionBlock)(void);

@end

@implementation CNKAudioManager

+ (CNKAudioManager *)sharedInstance{
    static CNKAudioManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CNKAudioManager alloc] init];
    });
    return instance;
}

- (instancetype)init{
    if (self = [super init]) {
        self.recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                               [NSNumber numberWithFloat:8000.00], AVSampleRateKey,
                               [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                               [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                               [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                               [NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey,
                               [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                               nil];
    }
    return self;
}

#pragma mark- record

- (void)startRecordShowUI:(BOOL)showUI{
    if (self.recorder.isRecording) {
        return;
    }
    
    if (showUI) {
        if (!_recordDisplayView) {
            _recordDisplayView = [CNKRecordDisplayView defaultDisplayView];
        }
        [_recordDisplayView setDisplayStatus:CNKRecordDisplayViewStatusNormal];
        [[UIApplication sharedApplication].keyWindow addSubview:_recordDisplayView];
    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return;
    }
    [audioSession setActive:YES error:&err];
    err = nil;
    if(err){
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return;
    }
    
    NSString *filePath=[NSString stringWithFormat:@"%@/audioFile%@.caf",[FCFileManager pathForCachesDirectory],[[NSProcessInfo processInfo] globallyUniqueString]];
    
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSData *existedData = [NSData dataWithContentsOfFile:[url path] options:NSDataReadingMapped error:&err];
    if (existedData) {
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:[url path] error:&err];
    }
    
    self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:self.recordSettings error:&err];
    [self.recorder setDelegate:self];
    [self.recorder prepareToRecord];
    [self.recorder setMeteringEnabled:YES];
    [self.recorder peakPowerForChannel:0.f];
    
    [self.recorder record];
    
    if (_recordDisplayView) {
        _recordInterval = 0;
        _timer = [CNKUtils mainQueueTimerWithInterval:0.1 eventBlock:^{
            _recordInterval += 0.1;
            [self.recorder updateMeters];
            CGFloat averagePower = [self.recorder averagePowerForChannel:0];
            if(averagePower < -45){
                averagePower = -45;
            }
            averagePower = (45+averagePower)/45;
            int powerInt = averagePower*10;
            powerInt = powerInt<1?1:powerInt;
            
            [_recordDisplayView setLevel:powerInt];
        }];
    }
}

- (void)stopRecordWithCompletionBlock:(void(^)(NSURL *audioContentOfUrl))completionBlock{
    if (_timer) {
        [CNKUtils cancelTimer:_timer];
    }
    
    _recordCompletionBlock = completionBlock;
    [self.recorder stop];
    
    if (_recordInterval < 1) {
        _recordInterval = 0;
        if (_recordDisplayView) {
            if (_recordDisplayView.displayStatus == CNKRecordDisplayViewStatusCancel) {
                [_recordDisplayView dismiss];
            } else {
                [_recordDisplayView setDisplayStatus:CNKRecordDisplayViewStatusToShort];
            }
        }
    } else {
        _recordInterval = 0;
        if (_recordDisplayView) {
            [_recordDisplayView dismiss];
        }
    }
}

#pragma mark- getter

- (BOOL)isRecording{
    return self.recorder.isRecording;
}

#pragma mark- AVAudioRecorderDelegate

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error{
    NSLog(@"error : %@",error);
    if (_recordCompletionBlock) {
        _recordCompletionBlock(nil);
    }
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    if (flag) {
        NSData *audioData = [NSData dataWithContentsOfURL:recorder.url];
        if (audioData) {
            [[CNKCache sharedInstance] setCacheObject:audioData forKey:[CNKUtils md5String:recorder.url.absoluteString]];
            if ([CNKAudioManager getAudioLength:audioData] >= 1) {
                if (_recordCompletionBlock) {
                    _recordCompletionBlock(recorder.url);
                }
            }
            return;
        }
    }
    
    if (_recordCompletionBlock) {
        _recordCompletionBlock(nil);
    }
}

#pragma mark- play

- (void)playWithMessage:(CNKChatMessageModel*)message completionBlock:(void(^)(void))completionBlock{
    if (message.msgContentType != CNKMSGContentTypeVoice || !message.msgContent) {
        if (completionBlock) {
            completionBlock();
        }
        return;
    }
    
    _playingAudioCacheKey = message.msgContentMd5Key;
    _playCompletionBlock = completionBlock;
    
    [CNKAudioManager getAudioDataWithMessage:message completionBlock:^(NSData *audioData) {
        if (audioData) {
            AVAudioSession *session = [AVAudioSession sharedInstance];
            [session setCategory:AVAudioSessionCategoryPlayback error:nil];
            //打开距离传感器
            [self changeProximityMonitorEnableState:YES];
            self.player = [[AVAudioPlayer alloc] initWithData:audioData error:nil];
            self.player.delegate = self;
            self.player.volume = 1.f;
            [self.player play];
            return;
        }
        if (_playCompletionBlock) {
            _playCompletionBlock();
        }
    }];    
}

- (void)stopPlayAudio{
    if (self.player.isPlaying) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"StopPlayChatAudio" object:_playingAudioCacheKey];
        _playingAudioCacheKey = nil;
        [self.player stop];
        if (_playCompletionBlock) {
            _playCompletionBlock();
        }
    }
}

- (BOOL)isPlaying{
    return self.player.isPlaying;
}

- (BOOL)isPlayingWithAudioCacheKey:(NSString *)audioCacheKey{
    if (self.player.isPlaying && _playingAudioCacheKey && [_playingAudioCacheKey isEqualToString:audioCacheKey]) {
        return YES;
    }
    return NO;
}

#pragma mark- AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self changeProximityMonitorEnableState:NO];
    _playingAudioCacheKey = nil;
    if (_playCompletionBlock) {
        _playCompletionBlock();
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    _playingAudioCacheKey = nil;
    if (_playCompletionBlock) {
        _playCompletionBlock();
    }
}

/**
 by donly
 http://magicalboy.com/using_iphone_proximity_sensor/
 */
#pragma mark - 近距离传感器

- (void)changeProximityMonitorEnableState:(BOOL)enable {
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
        if (enable) {
            //添加近距离事件监听，添加前先设置为YES，如果设置完后还是NO的读话，说明当前设备没有近距离传感器
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:) name:UIDeviceProximityStateDidChangeNotification object:nil];
        } else {
            //删除近距离事件监听
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        }
    }
}

- (void)sensorStateChange:(NSNotificationCenter *)notification {
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗
    if ([[UIDevice currentDevice] proximityState] == YES) {
        //黑屏
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    } else {
        //没黑屏幕
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        if (!_player || !_player.isPlaying) {
            //没有播放了
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
        }
    }
}

+ (NSTimeInterval) getAudioLengthWithAudioCacheKey:(NSString *)audioCacheKey{
    NSData *audioData = (NSData*)[[CNKCache sharedInstance] cacheObjectForKey:audioCacheKey];
    return [self getAudioLength:audioData];
}

+ (NSTimeInterval) getAudioLength:(NSData *) data {
    NSError * error;
    AVAudioPlayer *play = [[AVAudioPlayer alloc] initWithData:data error:&error];
    NSTimeInterval n = [play duration];
    return n;
}

#pragma mark- download audio data

+ (void)getAudioDataWithMessage:(CNKChatMessageModel *)message completionBlock:(void(^)(NSData *audioData))completionBlock{
    if (message.msgContentType != CNKMSGContentTypeVoice) {
        if (completionBlock) {
            completionBlock(nil);
        }
        return;
    }
    
    //get audio data from cache
    NSData *audioData = (NSData *)[[CNKCache sharedInstance] cacheObjectForKey:message.msgContentMd5Key];
    if (audioData) {
        if (completionBlock) {
            completionBlock(audioData);
        }
        return;
    }
    
    [CNKAudioManager getAudioDataWithUrl:message.msgContent completionBlock:completionBlock];
}

+ (void)getAudioDataWithUrl:(NSString *)audioUrl completionBlock:(void(^)(NSData *audioData))completionBlock{
    if (!audioUrl) {
        if (completionBlock) {
            completionBlock(nil);
        }
        return;
    }
    
    if ([CNKUtils isValidateURL:audioUrl]) {
        NSData *audioData = (NSData *)[[CNKCache sharedInstance] cacheObjectForKey:[CNKUtils md5String:audioUrl]];
        
        if (audioData) {
            if (completionBlock) {
                completionBlock(audioData);
            }
        } else {
            [[TCBlobDownloadManager sharedInstance] startDownloadWithURL:[NSURL URLWithString:audioUrl] customPath:nil firstResponse:nil progress:nil error:^(NSError *error) {
                if (completionBlock) {
                    completionBlock(nil);
                }
            } complete:^(BOOL downloadFinished, NSString *pathToFile) {
                if (downloadFinished) {
                    [CNKUtils executeBlockInGlobalQueue:^{
                        NSData *audioData = [NSData dataWithContentsOfFile:pathToFile];
                        if (audioData) {
                            [[CNKCache sharedInstance] setCacheObject:audioData forKey:[CNKUtils md5String:audioUrl]];
                            [CNKUtils executeBlockInMainQueue:^{
                                if (completionBlock) {
                                    completionBlock(audioData);
                                }
                            }];
                            return;
                        }
                    }];
                }
                if (completionBlock) {
                    completionBlock(nil);
                }
            }];
        }
    } else {
        //非url 从本地文件获取
        [CNKUtils executeBlockInGlobalQueue:^{
            NSData *audioData = [NSData dataWithContentsOfURL:[NSURL URLWithString:audioUrl]];
            if (audioData) {
                [[CNKCache sharedInstance] setCacheObject:audioData forKey:[CNKUtils md5String:audioUrl]];
            }
            [CNKUtils executeBlockInMainQueue:^{
                if (completionBlock) {
                    completionBlock(audioData);
                }
            }];
        }];
    }
}
@end
