//
//  DSKNetKit.h
//  DiverStarKit
//
//  Created by Frcc on 15/7/1.
//  Copyright (c) 2015年 DiverStar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
typedef enum{
    NotShow = 0, //不显示菊花
    Show, //显示菊花,不锁屏幕
    Showandlock, //显示菊花并锁住屏幕
    Showandlockclear, //显示菊花并锁住屏幕没有灰色背景
    Custom,
    Customlock,
    Customlockclear
}ShowHUB;

typedef enum{
    Unknown,
    NoNet,
    WIFI,
    WWAN
}DSKNeStutas;

@interface DSKNetKit : NSObject
//typedef void (^netOpBlock)(AFHTTPRequestOperation *op);
typedef void (^netSuccessBlock)(NSDictionary *dictionary);
typedef void (^netErrorBlock)(NSError *error,id errorMessageOrErrorCode);
@property (nonatomic,strong,readonly) AFHTTPSessionManager *manager;
+ (void)setNeedOriginJsonString:(BOOL)yesOrNo;  //是否需要原始的报文 ， 对应奇葩需求 key=@"originJsonString"

+ (void)setUpBaseServer:(NSString*)server; //需优先设置

+ (void)setHttpsAllowInvalidCertificates:(BOOL)yesOrNo; //需优先设置

+ (DSKNetKit*)shareInstance;

+ (void)setPreRequestAOPProxy:(void (^)(ShowHUB sh))cb;  //请求开始前的回调，主要用于自定义菊花。

//sh 也可传 0 1 2 3
- (void)POST:(NSString*)url parameters:(NSDictionary*)param ShowHub:(ShowHUB)sh Sucess:(netSuccessBlock)sb Error:(netErrorBlock)eb;
- (void)GET:(NSString*)url parameters:(NSDictionary*)param ShowHub:(ShowHUB)sh Sucess:(netSuccessBlock)sb Error:(netErrorBlock)eb;
//- (void)GET:(NSString*)url parameters:(NSDictionary*)param ShowHub:(ShowHUB)sh Sucess:(netSuccessBlock)sb Error:(netErrorBlock)eb opBlock:(netOpBlock)op;
- (void)HEAD:(NSString*)url parameters:(NSDictionary*)param ShowHub:(ShowHUB)sh Sucess:(netSuccessBlock)sb Error:(netErrorBlock)eb;
- (void)DELETE:(NSString*)url parameters:(NSDictionary*)param ShowHub:(ShowHUB)sh Sucess:(netSuccessBlock)sb Error:(netErrorBlock)eb;
- (void)HTTP:(NSMutableURLRequest *)request;
//参照如下代码传入Request,与baseServer无关联。
//NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:serverUrl parameters:param constructingBodyWithBlock:^(id formData) {
//    [formData appendPartWithFileURL:filePath name:@"file_1" error:nil];
//    [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 1) name:@"file_2" fileName:@"cover" mimeType:@"image/jpeg"];
//    [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 0.5) name:@"file_3" fileName:@"coverThumbnail" mimeType:@"image/jpeg"];
//} error:nil];
- (void)upLoadFileWithRequest:(NSMutableURLRequest*)request progressBlock:(void (^)(float))pb Success:(netSuccessBlock)sb Error:(netErrorBlock)eb;

//传入需下载文档的完整路径，与baseServer无关联。  folder=nil,则默认为down,@"mydownfloder/down"前后不佳\  filename=nil,则默认随机uuid。fileType为文件后缀，==nil,则不加后缀。@"mp4",不要加 '.' 。
- (void)downloadFileWithFileUrl:(NSString*)fileUrl progressBlock:(void (^)(float))pb inFolder:(NSString*)folder fileName:(NSString*)filename fileType:(NSString*)filetype Success:(void (^)(NSURL *filepath))sb Error:(netErrorBlock)eb;

//将kv封装到字典里面，设置一次，以后的请求都会有效。
- (void)setHeader:(NSDictionary*)dic;

//网络请求成功后的切面，可以统一处理数据。比如 successCode = @"000000",则可在此方法中判断，如相同则表示服务器处理成功可回调sb，反之则调用eb或alert提示。
+ (void)setSuccessAOPProxy:(void (^)(NSDictionary *data,netSuccessBlock sb,netErrorBlock eb))saop;
//网络请求失败后的切面(最多的情况是：无网络、网络超时、服务器无响应)，可以统一处理相关错误。如统一弹出alert提示。
+ (void)setErrorAOPProxy:(void (^)(NSError *error,netErrorBlock eb))eaop;
//在网络请求之前，給所有参数附加这里预设的参数。
+ (void)setPresetParams:(NSDictionary*)dic;
////在网络请求之前，返回预设的参数方法。
+ (void)setPresetParamsCallBack:(NSDictionary* (^)(void))cb;

//获取当前网络状态
- (DSKNeStutas)getNetworkReachabilityStatus;
//监听网络状态变化
- (void)setReachabilityStatusChangeBlock:(void (^)(DSKNeStutas stutas))block;

- (void)ReSetBaseServer:(NSString*)server;

+ (void)setTimeOut:(NSTimeInterval)timeout; //默认60s

- (NSString*)getBaseServer;

- (void)reTryLastOperation; //重试上次不成功的请求，仅指服务器没有响应的请求。只保留上一次不成功的，下次成功马上就被清除置nil.

- (void)cancelAllOperation; //取消所有请求



@end
