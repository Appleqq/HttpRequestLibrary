//
//  DSKNetKit+RequestModel.h
//  SPRequestLibrary
//
//  Created by ppan on 2018/4/11.
//  Copyright © 2018年 ppan. All rights reserved.
//

#import "DSKNetKit.h"

@interface DSKNetKit (RequestModel)

/**
 请求参数为model，返回为json

 @param urlString url
 @param requestModel 请求的model
 @param success 成功的block
 @param failure 失败的block
 @return task
 */
- (NSURLSessionDataTask *)requestJsonWithUrl:(NSString *)urlString
                                requestModel:(id)requestModel
                                     success:(void(^)(NSURLSessionDataTask *task ,id json , NSString *message))success
                                      filure:(void(^)(NSURLSessionDataTask *task, NSString *error))failure;

/**
 请求参数为model ,返回为model

 @param urlString url
 @param requestModel 请求的model
 @param modelClass 返回的model
 @param modelKey model对应的件
 @param success 成功的block
 @param failure 失败的block
 @return task
 */
- (NSURLSessionDataTask *)requestModelWithUrl:(NSString *)urlString
                                 requestModel:(id)requestModel
                                   modelClass:(Class)modelClass
                                     modelKey:(NSString *)modelKey
                                      success:(void(^)(NSURLSessionDataTask *task, id model ,NSString *message))success
                                      failure:(void(^)(NSURLSessionDataTask *task ,NSString *error))failure;


/**
 请求参数为model,返回为model，无modelKey

 @param URLString url
 @param requestModel 请求model
 @param modelClass  model 类型
 @param success  成功block
 @param failure 失败block
 @return task
 */
- (NSURLSessionDataTask *)requestModelWithUrl:(NSString *)URLString
                                 requestModel:(id)requestModel
                                   modelClass:(Class)modelClass
                                      success:(void (^)(NSURLSessionDataTask *task, id model ,NSString *message))success
                                      failure:(void (^)(NSURLSessionDataTask *task, NSString *error))failure;


/**
 请求参数为model，返回为模型对应的数组

 @param urlString url
 @param requestModel 请求model
 @param modelClass 返回的model类型
 @param modelArrkey key
 @param success 成功
 @param failure 失败
 @return task
 */
- (NSURLSessionDataTask *)requestModelArrWithUrl:(NSString *)urlString
                                    requestModel:(id)requestModel
                                      modelClass:(Class)modelClass
                                      modeArrKey:(NSString *)modelArrkey
                                         success:(void (^)(NSURLSessionDataTask *task, NSArray *modelArr ,NSString *message))success
                                         failure:(void (^)(NSURLSessionDataTask *task, NSString *error))failure;

- (NSURLSessionDataTask *)requestModelArrWithUrl:(NSString *)URLString
                                    requestModel:(id)requestModel
                                      modelClass:(Class)modelClass
                                         success:(void (^)(NSURLSessionDataTask *task, NSArray *modelArr ,NSString *message))success
                                         failure:(void (^)(NSURLSessionDataTask *task, NSString *error))failure;


/**
 请求返回model

 @param urlString url
 @param parameters 参数
 @param modelClass model类型
 @param modelKey model的key
 @param success 成功的block
 @param failure 失败的block
 @return task
 */
- (NSURLSessionDataTask *)requestModelWithUrl:(NSString *)urlString
                                   parmarters:(id)parameters
                                   modelClass:(Class)modelClass
                                     modelKey:(NSString *)modelKey
                                      success:(void(^)(NSURLSessionDataTask *task ,id model, NSString *message))success
                                      failure:(void(^)(NSURLSessionDataTask *task,NSString *error))failure;

/**
 请求返回json
 
 @param URLString 接口
 @param parameters 参数
 @param success 成功回调
 @param failure 失败回调
 @return 请求任务
 */
- (NSURLSessionDataTask *)requestJsonWithUrl:(NSString *)URLString
                                  parameters:(id)parameters
                                     success:(void (^)(NSURLSessionDataTask *task, id json ,NSString *message))success
                                     failure:(void (^)(NSURLSessionDataTask *task, NSString *error))failure;
// 最终发送请求函数
- (NSURLSessionDataTask *)publishRequestWithUrl:(NSString *)URLString
                                     parameters:(id)parameters
                                        success:(void (^)(NSURLSessionDataTask *task, NSData *content))success
                                        failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
@end
