//
//  CNKAudioManager.h
//  CNKChat
//
//  Created by chenkai on 2016/11/17.
//  Copyright © 2016年 chenkai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CNKRecordDisplayView.h"

@class CNKChatMessageModel;
@interface CNKAudioManager : NSObject

+ (CNKAudioManager *)sharedInstance;

#pragma mark- record
@property(nonatomic, strong) CNKRecordDisplayView *recordDisplayView;
@property (nonatomic, assign) BOOL isRecording;

- (void)startRecordShowUI:(BOOL)showUI;

- (void)stopRecordWithCompletionBlock:(void(^)(NSURL *audioContentOfUrl))completionBlock;

#pragma mark- play
@property (nonatomic, assign) BOOL isPlaying;

- (void)playWithMessage:(CNKChatMessageModel*)message completionBlock:(void(^)(void))completionBlock;

- (void)stopPlayAudio;

- (BOOL)isPlayingWithAudioCacheKey:(NSString *)audioCacheKey;

+ (NSTimeInterval) getAudioLengthWithAudioCacheKey:(NSString *)audioCacheKey;

+ (NSTimeInterval) getAudioLength:(NSData *) data;

#pragma mark- download audio data
//获取语音数据，包括本地缓存数据和网络端数据
+ (void)getAudioDataWithMessage:(CNKChatMessageModel *)message completionBlock:(void(^)(NSData *audioData))completionBlock;

//获取网络端语音数据
+ (void)getAudioDataWithUrl:(NSString *)audioUrl completionBlock:(void(^)(NSData *audioData))completionBlock;

@end
