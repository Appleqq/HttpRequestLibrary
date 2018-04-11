//
//  DSKNetKit.m
//  DiverStarKit
//
//  Created by Frcc on 15/7/1.
//  Copyright (c) 2015年 DiverStar. All rights reserved.
//

#import "DSKNetKit.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"

@interface DSKNetKit ()



@end

@implementation DSKNetKit

static NSString *baseServer = nil;
static bool httpsAllowInvalidCertificates=YES;
static void (^proBlock)(float);
static void (^fsaop)(NSDictionary *, netSuccessBlock, netErrorBlock);
static void (^feaop)(NSError *, netErrorBlock);
static AFNetworkReachabilityStatus fstatus;
static void (^fdskNetStutas)(DSKNeStutas);
static NSDictionary *presetDic=nil;
static NSDictionary *(^preParamCb)(void);
static NSTimeInterval dsktimeout;
//static AFHTTPRequestOperation *lastOperation = nil;
static bool needOriginJsonString = NO;
static void (^preRequestAOPcb)(ShowHUB sh);

+ (void)setUpBaseServer:(NSString *)server{
    baseServer = server;
}

+ (void)setHttpsAllowInvalidCertificates:(BOOL)yesOrNo{
    httpsAllowInvalidCertificates = yesOrNo;
}

+ (void)setTimeOut:(NSTimeInterval)timeout{
    dsktimeout = timeout;
}

+ (DSKNetKit*)shareInstance{
    if (!baseServer) {
        NSLog(@"ERROR: baseServer is nil,please call setUpBaseServer:@\"youe server\"");
    }
    if (httpsAllowInvalidCertificates) {
        NSLog(@"warn: httpsAllowInvalidCertificates is YES");
    }
    if (baseServer) {
        static DSKNetKit *instance = nil;
        static dispatch_once_t onceQueue;
        dispatch_once(&onceQueue, ^{
            instance = [[DSKNetKit alloc] init];
        });
        return instance;
    }else
        return nil;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:baseServer]];
        _manager.requestSerializer.HTTPShouldHandleCookies = YES;
        [(AFJSONResponseSerializer*)_manager.responseSerializer setRemovesKeysWithNullValues:YES];
     //   [(AFJSONResponseSerializer*)_manager.responseSerializer setNeedOriginJsonString:needOriginJsonString];
        _manager.requestSerializer.timeoutInterval = dsktimeout;
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
        securityPolicy.allowInvalidCertificates = httpsAllowInvalidCertificates;
        _manager.securityPolicy = securityPolicy;
        [self monitorNet];
    }
    return self;
}

- (void)ReSetBaseServer:(NSString *)server{
    _manager=nil;
    _manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:server]];
    _manager.requestSerializer.HTTPShouldHandleCookies = YES;
    [(AFJSONResponseSerializer*)_manager.responseSerializer setRemovesKeysWithNullValues:YES];
   // [(AFJSONResponseSerializer*)_manager.responseSerializer setNeedOriginJsonString:needOriginJsonString];
    _manager.requestSerializer.timeoutInterval = dsktimeout;
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = httpsAllowInvalidCertificates;
    _manager.securityPolicy = securityPolicy;
}

- (void)monitorNet{
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
        fstatus = status;
        
        switch (fstatus) {
            case AFNetworkReachabilityStatusUnknown:{
                if (fdskNetStutas) {
                    fdskNetStutas(Unknown);
                }
                break;
            }
            case AFNetworkReachabilityStatusNotReachable:{
                if (fdskNetStutas) {
                    fdskNetStutas(NoNet);
                }
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWiFi:{
                if (fdskNetStutas) {
                    fdskNetStutas(WIFI);
                }
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWWAN:{
                if (fdskNetStutas) {
                    fdskNetStutas(WWAN);
                }
                break;
            }
            default:
                if (fdskNetStutas) {
                    fdskNetStutas(Unknown);
                }
                break;
        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)POST:(NSString*)url parameters:(NSDictionary*)param ShowHub:(ShowHUB)sh Sucess:(netSuccessBlock)sb Error:(netErrorBlock)eb{
    if (sh == Show) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD show];
        });
    }
    if (sh == Showandlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD setDefaultMaskType:3];
        });
    }
    if (sh == Showandlockclear) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD setDefaultMaskType:2];
        });
    }
    if (preRequestAOPcb) {
        preRequestAOPcb(sh);
    }
    NSMutableDictionary *dicp = [NSMutableDictionary dictionaryWithDictionary:param];
    if (presetDic) {
        [dicp addEntriesFromDictionary:presetDic];
    }
    if (preParamCb) {
        [dicp addEntriesFromDictionary:preParamCb()];
    }
    //lastOperation = nil;
    [_manager  POST:url parameters:dicp progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (fsaop) {
            fsaop(responseObject,sb,eb);
        }else{
            sb(responseObject);
        }
        [SVProgressHUD dismiss];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (feaop) {
            feaop(error,eb);
        }else{
            eb(error,task);
        }
        [SVProgressHUD dismiss];
    }];
}

//- (void)lastlastOperation:(AFHTTPRequestOperation*)aop Sb:(netSuccessBlock)sb Eb:(netErrorBlock)eb{
//    lastOperation=[aop copy];
//    [lastOperation setCompletionBlockWithSuccess:^void(AFHTTPRequestOperation *aop , id data) {
//        if (fsaop) {
//            fsaop(data,sb,eb);
//        }else{
//            sb(data);
//        }
//        lastOperation = nil;
//        [SVProgressHUD dismiss];
//    } failure:^void(AFHTTPRequestOperation * aop, NSError * error) {
//        if (feaop) {
//            feaop(error,eb);
//        }else{
//            eb(error,aop);
//        }
//        [self lastlastOperation:aop Sb:sb Eb:eb];
//        [SVProgressHUD dismiss];
//    }];
//}

- (void)GET:(NSString*)url parameters:(NSDictionary*)param ShowHub:(ShowHUB)sh Sucess:(netSuccessBlock)sb Error:(netErrorBlock)eb{
   
    if (sh == Show) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD show];
        });
    }
    if (sh == Showandlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD setDefaultMaskType:3];
        });
    }
    if (sh == Showandlockclear) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD setDefaultMaskType:2];
        });
    }
    if (preRequestAOPcb) {
        preRequestAOPcb(sh);
    }
    NSMutableDictionary *dicp = [NSMutableDictionary dictionaryWithDictionary:param];
    if (presetDic) {
        [dicp addEntriesFromDictionary:presetDic];
    }
    if (preParamCb) {
        [dicp addEntriesFromDictionary:preParamCb()];
    }
    [_manager GET:url parameters:dicp progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@,%@",task,responseObject);
        if (fsaop) {
                fsaop(responseObject,sb,eb);
            }else{
                    sb(responseObject);
            }
        [SVProgressHUD dismiss];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (feaop) {
            feaop(error,eb);
        }else{
            eb(error,task);
        }
        [SVProgressHUD dismiss];
    }];
}
//- (void)GET:(NSString*)url parameters:(NSDictionary*)param ShowHub:(ShowHUB)sh Sucess:(netSuccessBlock)sb Error:(netErrorBlock)eb opBlock:(netOpBlock)op {
//    if (sh == Show) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [SVProgressHUD show];
//        });
//    }
//    if (sh == Showandlock) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [SVProgressHUD setDefaultMaskType:3];
//        });
//    }
//    if (sh == Showandlockclear) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [SVProgressHUD setDefaultMaskType:2];
//        });
//    }
//    if (preRequestAOPcb) {
//        preRequestAOPcb(sh);
//    }
//    NSMutableDictionary *dicp = [NSMutableDictionary dictionaryWithDictionary:param];
//    if (presetDic) {
//        [dicp addEntriesFromDictionary:presetDic];
//    }
//    if (preParamCb) {
//        [dicp addEntriesFromDictionary:preParamCb()];
//    }
//    lastOperation = nil;
//    [_manager GET:url parameters:dicp success:^void(AFHTTPRequestOperation *aop , id data) {
//        NSLog(@"%@,%@",aop,data);
//        if (fsaop) {
//            fsaop(data,sb,eb);
//        }else{
//            sb(data);
//            op(aop);
//        }
//        lastOperation = nil;
//        [SVProgressHUD dismiss];
//    } failure:^void(AFHTTPRequestOperation * aop, NSError * error) {
//
//        if (feaop) {
//            feaop(error,eb);
//        }else{
//            eb(error,aop);
//        }
//        [self lastlastOperation:aop Sb:sb Eb:eb];
//        [SVProgressHUD dismiss];
//    }];
//}
- (void)HEAD:(NSString*)url parameters:(NSDictionary*)param ShowHub:(ShowHUB)sh Sucess:(netSuccessBlock)sb Error:(netErrorBlock)eb{
    if (sh == Show) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD show];
        });
    }
    if (sh == Showandlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD setDefaultStyle:3];
        });
    }
    if (sh == Showandlockclear) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD setDefaultStyle:2];
        });
    }
    if (preRequestAOPcb) {
        preRequestAOPcb(sh);
    }
    NSMutableDictionary *dicp = [NSMutableDictionary dictionaryWithDictionary:param];
    if (presetDic) {
        [dicp addEntriesFromDictionary:presetDic];
    }
    if (preParamCb) {
        [dicp addEntriesFromDictionary:preParamCb()];
    }
    [_manager HEAD:url parameters:dicp success:^(NSURLSessionDataTask * _Nonnull task) {
        if (fsaop) {
            fsaop(nil,sb,eb);
        }else{
            sb(nil);
        }
        [SVProgressHUD dismiss];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (feaop) {
            feaop(error,eb);
        }else{
            eb(error,task);
        }
        [SVProgressHUD dismiss];
    }];
//    lastOperation = nil;
//    [_manager HEAD:url parameters:dicp success:^void(AFHTTPRequestOperation *aop) {
//        if (fsaop) {
//            fsaop(nil,sb,eb);
//        }else{
//            sb(nil);
//        }
//        lastOperation = nil;
//        [SVProgressHUD dismiss];
//    } failure:^void(AFHTTPRequestOperation * aop, NSError * error) {
//        if (feaop) {
//            feaop(error,eb);
//        }else{
//            eb(error,aop);
//        }
//        [self lastlastOperation:aop Sb:sb Eb:eb];
//        [SVProgressHUD dismiss];
//    }];
}

- (void)DELETE:(NSString*)url parameters:(NSDictionary*)param ShowHub:(ShowHUB)sh Sucess:(netSuccessBlock)sb Error:(netErrorBlock)eb{
    if (sh == Show) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD show];
        });
    }
    if (sh == Showandlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD setDefaultMaskType:3];
        });
    }
    if (sh == Showandlockclear) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD setDefaultMaskType:2];
        });
    }
    if (preRequestAOPcb) {
        preRequestAOPcb(sh);
    }
    NSMutableDictionary *dicp = [NSMutableDictionary dictionaryWithDictionary:param];
    if (presetDic) {
        [dicp addEntriesFromDictionary:presetDic];
    }
    if (preParamCb) {
        [dicp addEntriesFromDictionary:preParamCb()];
    }
    [_manager DELETE:url parameters:dicp success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (fsaop) {
            fsaop(responseObject,sb,eb);
        }else{
            sb(responseObject);
        }
        [SVProgressHUD dismiss];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (feaop) {
            feaop(error,eb);
        }else{
            eb(error,task);
        }
        [SVProgressHUD dismiss];
    }];
}

- (void)upLoadFileWithRequest:(NSMutableURLRequest*)request progressBlock:(void (^)(float))pb Success:(netSuccessBlock)sb Error:(netErrorBlock)eb{
    
    proBlock = [pb copy];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = httpsAllowInvalidCertificates;
    manager.securityPolicy = securityPolicy;
    
  __block  NSProgress *progress = nil;
    
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
        progress = uploadProgress;
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        [progress removeObserver:self forKeyPath:@"fractionCompleted"];
        if (error) {
            if (feaop) {
                feaop(error,eb);
            }else{
                eb(error,[error localizedDescription]);
            }
        } else {
            if (fsaop) {
                fsaop(responseObject,sb,eb);
            }else{
                sb(responseObject);
            }
        }
    }];
    [progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:NULL];
    [uploadTask resume];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (proBlock) {
            proBlock([object fractionCompleted]);
        }
    });
}

- (void)downloadFileWithFileUrl:(NSString*)fileUrl progressBlock:(void (^)(float))pb inFolder:(NSString*)folder fileName:(NSString*)filename fileType:(NSString*)filetype Success:(void (^)(NSURL *filepath))sb Error:(netErrorBlock)eb{
    proBlock = [pb copy];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [[paths lastObject] stringByAppendingPathComponent:folder];
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm createDirectoryAtPath:docPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSURL *URL = [NSURL URLWithString:fileUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSProgress *progress = nil;
    
    __block NSString *__folder = folder;
    __block NSString *__filename = filename;
    __block NSString *__filetype = filetype;
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
    
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        if (!__folder) {
            __folder = @"down";
        }
        if (!__filename) {
            __filename = [self getUniqueStrByUUID];
        }
        if (__filetype) {
            __filename = [filename stringByAppendingFormat:@".%@",__filetype];
        }
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [[documentsDirectoryURL URLByAppendingPathComponent:__folder] URLByAppendingPathComponent:__filename];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        [progress removeObserver:self forKeyPath:@"fractionCompleted"];
        if (error) {
            if (feaop) {
                feaop(error,eb);
            }else{
                eb(error,[error localizedDescription]);
            }
        } else {
            sb(filePath);
        }
    }];
    
    [progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:NULL];
    
    [downloadTask resume];
}

- (NSString *)getUniqueStrByUUID{
    CFUUIDRef uuidObj = CFUUIDCreate(nil);//create a new UUID
    //get the string representation of the UUID
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    return uuidString ;
}

- (void)setHeader:(NSDictionary *)dic{
    NSArray *keys = [dic allKeys];
    for (NSString *key in keys) {
        [_manager.requestSerializer setValue:[dic objectForKey:key] forHTTPHeaderField:key];
    }
}

+ (void)setSuccessAOPProxy:(void (^)(NSDictionary *, netSuccessBlock, netErrorBlock))saop{
    fsaop = [saop copy];
}

+ (void)setErrorAOPProxy:(void (^)(NSError *, netErrorBlock))eaop{
    feaop = [eaop copy];
}

- (DSKNeStutas)getNetworkReachabilityStatus{
    switch (fstatus) {
        case AFNetworkReachabilityStatusUnknown:{
            return Unknown;
            break;
        }
        case AFNetworkReachabilityStatusNotReachable:{
            return NoNet;
            break;
        }
        case AFNetworkReachabilityStatusReachableViaWiFi:{
            return WIFI;
            break;
        }
        case AFNetworkReachabilityStatusReachableViaWWAN:{
            return WWAN;
            break;
        }
        default:
            return Unknown;
            break;
    }
}

- (void)setReachabilityStatusChangeBlock:(void (^)(DSKNeStutas))block{
    fdskNetStutas = [block copy];
}

+ (void)setPresetParams:(NSDictionary *)dic{
    presetDic = dic;
}

+ (void)setPresetParamsCallBack:(NSDictionary *(^)(void))cb{
    preParamCb = [cb copy];
}

- (NSString *)getBaseServer{
    return _manager.baseURL.absoluteString;
}

- (void)reTryLastOperation{
//    if (lastOperation) {
//        [_manager.operationQueue addOperation:lastOperation];
//    }
}

- (void)cancelAllOperation{
    [_manager.operationQueue cancelAllOperations];
}

+ (void)setNeedOriginJsonString:(BOOL)yesOrNo{
    needOriginJsonString = yesOrNo;
}

+ (void)setPreRequestAOPProxy:(void (^)(ShowHUB sh))cb{
    preRequestAOPcb = [cb copy];
}
- (void)HTTP:(NSMutableURLRequest *)request {

//    _manager 
//    [_manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
//       
//
//    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
//        
//    }];
}
@end
