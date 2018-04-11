//
//  DSKNetKit+RequestModel.m
//  SPRequestLibrary
//
//  Created by ppan on 2018/4/11.
//  Copyright © 2018年 ppan. All rights reserved.
//

#import "DSKNetKit+RequestModel.h"
#import "DSDataTransformerTool.h"
#define isNullClass(x)             (!x || [x isKindOfClass:[NSNull class]])
@implementation DSKNetKit (RequestModel)
- (NSURLSessionDataTask *)requestJsonWithUrl:(NSString *)urlString requestModel:(id)requestModel success:(void (^)(NSURLSessionDataTask *, id, NSString *))success filure:(void (^)(NSURLSessionDataTask *, NSString *))failure {
    
    NSDictionary *parmars = [DSDataTransformerTool getJsonWithModel:requestModel];
    
    return [self requestJsonWithUrl:urlString requestModel:parmars success:success filure:failure];
}
- (NSURLSessionDataTask *)requestModelWithUrl:(NSString *)urlString requestModel:(id)requestModel modelClass:(Class)modelClass modelKey:(NSString *)modelKey success:(void (^)(NSURLSessionDataTask *, id, NSString *))success failure:(void (^)(NSURLSessionDataTask *, NSString *))failure {
    
    NSDictionary *parameters = [DSDataTransformerTool getJsonWithModel:requestModel];
    return [self requestModelWithUrl:urlString parmarters:parameters modelClass:modelClass modelKey:modelKey success:success failure:failure];
}

- (NSURLSessionDataTask *)requestModelWithUrl:(NSString *)URLString
                                 requestModel:(id)requestModel
                                   modelClass:(Class)modelClass
                                      success:(void (^)(NSURLSessionDataTask *, id, NSString *))success
                                      failure:(void (^)(NSURLSessionDataTask *, NSString *))failure{
    
    NSDictionary *parameters = [DSDataTransformerTool getJsonWithModel:requestModel];
    
    return [self requestModelWithUrl:URLString parameters:parameters modelClass:modelClass success:success failure:failure];
}

- (NSURLSessionDataTask *)requestModelArrWithUrl:(NSString *)URLString
                                    requestModel:(id)requestModel
                                      modelClass:(Class)modelClass
                                         success:(void (^)(NSURLSessionDataTask *task, NSArray *modelArr ,NSString *message))success
                                         failure:(void (^)(NSURLSessionDataTask *task, NSString *error))failure {
    NSDictionary *parameters = [DSDataTransformerTool getJsonWithModel:requestModel];
    
    return [self requestModelArrWithUrl:URLString parameters:parameters modelClass:modelClass success:success failure:failure];
}

- (NSURLSessionDataTask *)requestModelArrWithUrl:(NSString *)URLString
                                      parameters:(id)parameters modelClass:(Class)modelClass
                                         success:(void (^)(NSURLSessionDataTask *, NSArray *, NSString *))success
                                         failure:(void (^)(NSURLSessionDataTask *, NSString *))failure{
    
    return [self requestModelArrWithUrl:URLString parameters:parameters modelClass:modelClass modelArrKey:nil success:success failure:failure];
}

- (NSURLSessionDataTask *)requestModelArrWithUrl:(NSString *)urlString requestModel:(id)requestModel modelClass:(Class)modelClass modeArrKey:(NSString *)modelArrkey success:(void (^)(NSURLSessionDataTask *, NSArray *, NSString *))success failure:(void (^)(NSURLSessionDataTask *, NSString *))failure {
    NSDictionary *parameters = [DSDataTransformerTool getJsonWithModel:requestModel];
    
    return [self requestModelArrWithUrl:urlString parameters:parameters modelClass:modelClass modelArrKey:modelArrkey success:success failure:failure];
}

- (NSURLSessionDataTask *)requestModelArrWithUrl:(NSString *)URLString
                                      parameters:(id)parameters
                                      modelClass:(Class)modelClass
                                     modelArrKey:(NSString *)modelArrKey
                                         success:(void (^)(NSURLSessionDataTask *, NSArray *, NSString *))success
                                         failure:(void (^)(NSURLSessionDataTask *, NSString *))failure{
    
    return [self requestJsonWithUrl:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id json, NSString *message) {
        
        if (modelArrKey) {
            
            json = json[modelArrKey];
        }
        json = (NSArray *)json;
        NSArray *modelArr = [DSDataTransformerTool getModelArr:modelClass json:json[@"content"]];
        
        if (modelArr == nil && isNullClass(json) == NO) {
            failure(task ,@"json转modelArr错误");
        }else{
            
            success(task ,modelArr ,message);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        
        failure(task ,error);
    }];
}
- (NSURLSessionDataTask *)requestModelWithUrl:(NSString *)URLString
                                   parameters:(id)parameters
                                   modelClass:(Class)modelClass
                                      success:(void (^)(NSURLSessionDataTask *, id ,NSString *))success
                                      failure:(void (^)(NSURLSessionDataTask *, NSString *))failure{
    
    return [self requestModelWithUrl:URLString parameters:parameters modelClass:modelClass modelKey:nil success:success failure:failure];
}

- (NSURLSessionDataTask *)requestModelWithUrl:(NSString *)urlString parmarters:(id)parameters modelClass:(Class)modelClass modelKey:(NSString *)modelKey success:(void (^)(NSURLSessionDataTask *, id, NSString *))success failure:(void (^)(NSURLSessionDataTask *, NSString *))failure {

    return [self requestJsonWithUrl:urlString requestModel:parameters success:^(NSURLSessionDataTask *task, id json, NSString *message) {
        if (modelKey) {
            json = json[modelKey];
        }
        id model = [DSDataTransformerTool getModel:modelClass json:json];
        if (model == nil && json) {
            failure(task,@"json转model错误");
        }else {
            success(task,model,message);
        }
    } filure:^(NSURLSessionDataTask *task, NSString *error) {
        failure(task,error);
    }];
}

- (NSURLSessionDataTask *)requestJsonWithUrl:(NSString *)URLString
                                  parameters:(id)parameters
                                     success:(void (^)(NSURLSessionDataTask *, id ,NSString *))success
                                     failure:(void (^)(NSURLSessionDataTask *, NSString *))failure{
    
    return [self publishRequestWithUrl:URLString parameters:parameters success:^(NSURLSessionDataTask *task, NSData *content) {
        
        if (content == nil||content.length==0||[content isKindOfClass:[NSNull class]]) {
            if (failure) failure(task ,@"服务器数据异常");
        }else{
            
            NSError *jsonError = nil;
            NSDictionary * json = [NSJSONSerialization JSONObjectWithData:content options:NSJSONReadingMutableContainers error:&jsonError] ;
            
            if (jsonError) {
                failure(task ,@"data 转 json 错误");
            }else{
                NSDictionary *result;
                result = json;
                NSNumber *code = json[@"result"];
                NSString *message = json[@"info"];
                int responseCode = [code intValue];
                
                if (responseCode == 1) {
                    
                    id responseObject = result;
                    success(task ,responseObject ,message);
                }else{
                    failure(task ,@"未知错误");
                    
                }
                
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(task ,error.description);
    }];
}
- (NSURLSessionDataTask *)requestModelWithUrl:(NSString *)URLString
                                   parameters:(id)parameters modelClass:(Class)modelClass
                                     modelKey:(NSString *)modelKey
                                      success:(void (^)(NSURLSessionDataTask *, id, NSString *))success
                                      failure:(void (^)(NSURLSessionDataTask *, NSString *))failure{
    
    return [self requestJsonWithUrl:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id json ,NSString *message) {
        
        if (modelKey) {
            
            json = json[modelKey];
        }
        
        id model = [DSDataTransformerTool getModel:modelClass json:json];
        
        if (model == nil&&json) {
            failure(task ,@"json转model错误");
        }else{
            
            success(task ,model ,message);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSString *error) {
        
        failure(task ,error.description);
    }];
    
}

- (NSURLSessionDataTask *)publishRequestWithUrl:(NSString *)URLString
                                     parameters:(id)parameters
                                        success:(void (^)(NSURLSessionDataTask *task, NSData *content))success
                                        failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure{
    
  NSURLSessionDataTask  *task = [self.manager POST:URLString parameters:parameters progress:nil success:success failure:failure];
    return task;
}
@end
