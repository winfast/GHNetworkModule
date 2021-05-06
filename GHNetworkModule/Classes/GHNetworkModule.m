//
//  GHNetworkModule.m
//  GHNetworkModule
//
//  Created by Qincc on 2020/12/12.
//

#import "GHNetworkModule.h"
#import <AFNetworking/AFNetworking.h>
#import "GHNetworkLogger.h"
#import "GHNetworkConfigure.h"
#import "GHNetworkResponse.h"
#import "GHNetworkRequest.h"
#import "GHNetworkCache.h"

@interface GHNetworkModule ()

@property (nonatomic, strong) NSMutableDictionary *reqeustDictionary;
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation GHNetworkModule

+ (nonnull instancetype)share
{
    static dispatch_once_t onceToken;
    static GHNetworkModule *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _requestInterceptorObjectArray = [NSMutableArray arrayWithCapacity:3];
        _responseInterceptorObjectArray = [NSMutableArray arrayWithCapacity:3];
        _reqeustDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (AFHTTPSessionManager *)sessionManager
{
    if (_sessionManager == nil){
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.HTTPMaximumConnectionsPerHost = 10; // 同一IP最大并发数
        _sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
        _sessionManager.responseSerializer = AFHTTPResponseSerializer.serializer; // 返回二进制，不可变更，返回值处理逻辑都是基于byte处理的
        _sessionManager.securityPolicy = [self customSecurityPolicy];
    }
    return _sessionManager;
}

- (AFSecurityPolicy *)customSecurityPolicy {
    NSData *data = [NSData dataWithContentsOfFile:GHNetworkConfigure.share.certificatePath];
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    securityPolicy.allowInvalidCertificates = NO;
    securityPolicy.validatesDomainName = NO;
    securityPolicy.pinnedCertificates = [NSSet.alloc initWithObjects:data, nil];
    return securityPolicy;
}

// MARK: - 🔥 Nomal Request
- (NSString *)sendRequest:(GHNetworkRequest *)request cacheComplete:(GHNetworkResponseBlock)cacheResult networkComplete:(GHNetworkResponseBlock)result
{
    // 拦截器处理
    if (![self needRequestInterceptor:request]) {
        if (GHNetworkConfigure.share.enableDebug) NSLog(@"该请求已经取消");
        return nil;
    }
    if (GHNetworkConfigure.share.enableDebug) [GHNetworkLogger logDebugInfoWithRequest:request];
    
    NSString *key = [NSString stringWithFormat:@"%@%@", request.baseURL, request.methodPath];
    if (cacheResult && GHNetworkConfigure.share.useCache) {
        id value = [GHNetworkCache syncReadCache:GHNetworkConfigure.share.userToken key:key];
        GHNetworkResponse *response = [GHNetworkResponse.alloc initWithCacheResponse:value];
        cacheResult(response);
    }
    
    return [self requestWithRequest:[request generateRequest] complete:^(GHNetworkResponse *response) {
        if (result) {
            //缓存数据
            result(response);
            if (cacheResult && response.status == GHNetworkResponseStatusSuccess && GHNetworkConfigure.share.useCache) {
                [GHNetworkCache asycWriteCache:GHNetworkConfigure.share.userToken key:key value:response.JSONObject completeBlock:^{
                    
                }];
            }
        }
    }];
}

- (NSString *)sendRequestWithConfigBlock:(GHRequestConfigBlock)requestBlock cacheComplete:(GHNetworkResponseBlock)cacheResult networkComplete:(GHNetworkResponseBlock) result;
{
    GHNetworkRequest *request = [[GHNetworkRequest alloc] init];
    requestBlock(request);
    // 拦截器处理
    if (![self needRequestInterceptor:request]) {
        if (GHNetworkConfigure.share.enableDebug) NSLog(@"该请求已经取消");
        return nil;
    }
    if (GHNetworkConfigure.share.enableDebug) [GHNetworkLogger logDebugInfoWithRequest:request];
    
    NSString *key = [NSString stringWithFormat:@"%@%@", request.baseURL, request.methodPath];
    if (cacheResult && GHNetworkConfigure.share.useCache) {
        id value = [GHNetworkCache syncReadCache:GHNetworkConfigure.share.userToken key:key];
        GHNetworkResponse *response = [GHNetworkResponse.alloc initWithCacheResponse:value];
        cacheResult(response);
    }
    
    return [self requestWithRequest:[request generateRequest] complete:^(GHNetworkResponse *response) {
        if (result) {
            //缓存数据
            result(response);
            if (cacheResult && response.status == GHNetworkResponseStatusSuccess && GHNetworkConfigure.share.useCache) {
                [GHNetworkCache asycWriteCache:GHNetworkConfigure.share.userToken key:key value:response.JSONObject completeBlock:nil];
            }
        }
    }];
}

- (NSString *)requestWithRequest:(NSURLRequest *)request complete:(GHNetworkResponseBlock)complete
{
    if (GHNetworkConfigure.share.startReachability &&
        [[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] != AFNetworkReachabilityStatusReachableViaWWAN &&
        [[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] != AFNetworkReachabilityStatusReachableViaWiFi) {
        
        NSError *error = [NSError errorWithDomain:NSLocalizedString(@"There seems to be a glitch in the network, please try again later", nil) code:-1009 userInfo:nil];
        [self requestFinishedWithBlock:complete task:nil data:nil error:error];
        return nil;
    }
    
    __block NSURLSessionDataTask *task = nil;
    task = [self.sessionManager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error && [response isKindOfClass:NSHTTPURLResponse.class]) {
            // 重写ERROR，重新code
            NSHTTPURLResponse *rsp = (NSHTTPURLResponse *)response;
            error = [NSError errorWithDomain:error.localizedDescription code:rsp.statusCode userInfo:error.userInfo];
        }
        [self.reqeustDictionary removeObjectForKey:@([task taskIdentifier])];
        [self requestFinishedWithBlock:complete task:task data:responseObject error:error];
    }];
    
    NSString *requestId = [[NSString alloc] initWithFormat:@"%@", @([task taskIdentifier])];
    self.reqeustDictionary[requestId] = task;
    [task resume];
    return requestId;
}

// MARK: - 🔥 Upload Request
- (NSString *_Nullable)sendUploadRequest:(nonnull GHNetworkRequest *)request formData:(NSData *)bodyData progress:(void (^)(NSProgress *uploadProgress))progress complete:(GHNetworkResponseBlock)result
{
    // 拦截器处理
    if (![self needRequestInterceptor:request]) {
        if (GHNetworkConfigure.share.enableDebug) NSLog(@"该请求已经取消");
        return nil;
    }
    if (GHNetworkConfigure.share.enableDebug) [GHNetworkLogger logDebugInfoWithRequest:request];
    return [self requestWithUploadRequest:[request generateRequest] formData:bodyData progress:progress complete:result];
}

- (NSString *_Nullable)sendUploadRequestWithConfigBlock:(nonnull GHRequestConfigBlock)requestBlock formData:(NSData *)bodyData progress:(void (^)(NSProgress *uploadProgress))progress complete:(nonnull GHNetworkResponseBlock)result
{
    GHNetworkRequest *request = [[GHNetworkRequest alloc] init];
    requestBlock(request);
    // 拦截器处理
    if (![self needRequestInterceptor:request]) {
        if (GHNetworkConfigure.share.enableDebug) NSLog(@"该请求已经取消");
        return nil;
    }
    if (GHNetworkConfigure.share.enableDebug) [GHNetworkLogger logDebugInfoWithRequest:request];
    return [self requestWithUploadRequest:[request generateRequest] formData:bodyData progress:progress complete:result];
}

- (NSString *)requestWithUploadRequest:(NSURLRequest *)request formData:(NSData *)bodyData progress:(void (^)(NSProgress *uploadProgress))progress complete:(GHNetworkResponseBlock)complete
{
    if (GHNetworkConfigure.share.startReachability &&
        [[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] != AFNetworkReachabilityStatusReachableViaWWAN &&
        [[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] != AFNetworkReachabilityStatusReachableViaWiFi) {
        
        NSError *error = [NSError errorWithDomain:NSLocalizedString(@"There seems to be a glitch in the network, please try again later", nil) code:-1009 userInfo:nil];
        [self requestFinishedWithBlock:complete task:nil data:nil error:error];
        return nil;
    }
    
    __block NSURLSessionUploadTask *task = nil;
    task = [self.sessionManager uploadTaskWithRequest:request fromData:bodyData progress:progress completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error && [response isKindOfClass:NSHTTPURLResponse.class]) {
            // 重写ERROR，重新code
            NSHTTPURLResponse *rsp = (NSHTTPURLResponse *)response;
            error = [NSError errorWithDomain:error.localizedDescription code:rsp.statusCode userInfo:error.userInfo];
        }
        
        [self.reqeustDictionary removeObjectForKey:@([task taskIdentifier])];
        
        /** ----- 自定义返回实体 ----- */
        NSMutableDictionary *result = NSMutableDictionary.dictionary;
        if (error == nil) {
            NSMutableDictionary *dic = NSMutableDictionary.dictionary;
            [dic setValue:response.URL.absoluteString forKey:@"uploadURL"];
            [result setValue:@(200) forKey:@"code"];
            [result setValue:dic forKey:@"data"];
            [result setValue:@"Upload Success" forKey:@"message"];
        } else {
            [result setValue:@(error.code) forKey:@"code"];
            [result setValue:error.domain forKey:@"message"];
        }
        NSData *data = [NSJSONSerialization dataWithJSONObject:result options:NSJSONWritingPrettyPrinted error:nil];
        /** ----- 自定义返回实体 ----- */
        
        [self requestFinishedWithBlock:complete task:task data:data error:error];
    }];
    
    NSString *requestId = [[NSString alloc] initWithFormat:@"%@", @([task taskIdentifier])];
    self.reqeustDictionary[requestId] = task;
    [task resume];
    return requestId;
}

// MARK: - 🔥 Download Request
- (NSString *_Nullable)sendDownloadRequest:(nonnull GHNetworkRequest *)request destination:(NSURL * (^)(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response))destination progress:(void (^)(NSProgress *downloadProgress))progress complete:(nonnull GHNetworkResponseBlock)result
{
    // 拦截器处理
    if (![self needRequestInterceptor:request]) {
        if (GHNetworkConfigure.share.enableDebug) NSLog(@"该请求已经取消");
        return nil;
    }
    
    if (GHNetworkConfigure.share.enableDebug) [GHNetworkLogger logDebugInfoWithRequest:request];
    return [self requestWithDownloadRequest:[request generateRequest] destination:destination progress:progress complete:result];
}

- (NSString *_Nullable)sendDownloadRequestWithConfigBlock:(nonnull GHRequestConfigBlock)requestBlock destination:(NSURL * (^)(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response))destination progress:(void (^)(NSProgress *downloadProgress))progress complete:(GHNetworkResponseBlock)result
{
    GHNetworkRequest *request = [[GHNetworkRequest alloc] init];
    requestBlock(request);
    // 拦截器处理
    if (![self needRequestInterceptor:request]) {
        if (GHNetworkConfigure.share.enableDebug) NSLog(@"该请求已经取消");
        return nil;
    }
    
    if (GHNetworkConfigure.share.enableDebug) [GHNetworkLogger logDebugInfoWithRequest:request];
    return [self requestWithDownloadRequest:[request generateRequest] destination:destination progress:progress complete:result];
}

- (NSString *)requestWithDownloadRequest:(NSURLRequest *)request destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse * _Nonnull response))destination progress:(void (^)(NSProgress *downloadProgress))progress complete:(GHNetworkResponseBlock)complete
{
    if (GHNetworkConfigure.share.startReachability &&
        [[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] != AFNetworkReachabilityStatusReachableViaWWAN &&
        [[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] != AFNetworkReachabilityStatusReachableViaWiFi) {
        
        NSError *error = [NSError errorWithDomain:NSLocalizedString(@"There seems to be a glitch in the network, please try again later", nil) code:-1009 userInfo:nil];
        [self requestFinishedWithBlock:complete task:nil data:nil error:error];
        return nil;
    }
    
    __block NSURLSessionDownloadTask *task = nil;
    task = [self.sessionManager downloadTaskWithRequest:request progress:progress destination:destination completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error && [response isKindOfClass:NSHTTPURLResponse.class]) {
            // 重写ERROR，重新code
            NSHTTPURLResponse *rsp = (NSHTTPURLResponse *)response;
            error = [NSError errorWithDomain:error.localizedDescription code:rsp.statusCode userInfo:error.userInfo];
        }
        
        [self.reqeustDictionary removeObjectForKey:@([task taskIdentifier])];
        
        /** ----- 自定义返回实体 ----- */
        NSMutableDictionary *result = NSMutableDictionary.dictionary;
        if (error == nil) {
            NSMutableDictionary *dic = NSMutableDictionary.dictionary;
            [dic setValue:response.URL.absoluteString forKey:@"downloadURL"];
            [dic setValue:filePath.absoluteString forKey:@"filePath"];
            [result setValue:@(200) forKey:@"code"];
            [result setValue:dic forKey:@"data"];
            [result setValue:@"Download Success" forKey:@"message"];
        } else {
            [result setValue:@(error.code) forKey:@"code"];
            [result setValue:error.domain forKey:@"message"];
        }
        NSData *data = [NSJSONSerialization dataWithJSONObject:result options:NSJSONWritingPrettyPrinted error:nil];
        /** ----- 自定义返回实体 ----- */
        
        [self requestFinishedWithBlock:complete task:task data:data error:error];
    }];
    
    NSString *requestId = [[NSString alloc] initWithFormat:@"%@", @([task taskIdentifier])];
    self.reqeustDictionary[requestId] = task;
    [task resume];
    return requestId;
}

// MARK: - 🔥 Finish Request
- (void)requestFinishedWithBlock:(GHNetworkResponseBlock)blk task:(NSURLSessionTask *)task data:(NSData *)data error:(NSError *)error
{
    if (GHNetworkConfigure.share.enableDebug) [GHNetworkLogger logDebugInfoWithTask:task data:data error:error];
    
    if (error) {
        GHNetworkResponse *rsp = [[GHNetworkResponse alloc] initWithRequestId:@([task taskIdentifier]) request:task.originalRequest responseData:data error:error];
        for (id obj in self.responseInterceptorObjectArray)
        {
            if ([obj respondsToSelector:@selector(validatorResponse:)])
            {
                [obj validatorResponse:rsp];
                break;
            }
        }
        blk ? blk(rsp) : nil;
    } else {
        GHNetworkResponse *rsp = [[GHNetworkResponse alloc] initWithRequestId:@([task taskIdentifier]) request:task.originalRequest responseData:data status:GHNetworkResponseStatusSuccess];
        for (id obj in self.responseInterceptorObjectArray)
        {
            if ([obj respondsToSelector:@selector(validatorResponse:)])
            {
                [obj validatorResponse:rsp];
                break;
            }
        }
        blk ? blk(rsp) : nil;
    }
}

// MARK: - 🔥 Cancle Request
- (void)cancelRequestWithRequestID:(nonnull NSString *)requestID
{
    if (requestID) {
        NSURLSessionDataTask *requestOperation = self.reqeustDictionary[requestID];
        [requestOperation cancel];
        [self.reqeustDictionary removeObjectForKey:requestID];
    }
}

- (void)cancelRequestWithRequestIDList:(nonnull NSArray<NSString *> *)requestIDList
{
    for (NSString *requestId in requestIDList){
        [self cancelRequestWithRequestID:requestId];
    }
}

// MARK: - 🔥 Intercept Request
- (BOOL)needRequestInterceptor:(GHNetworkRequest *)request
{
    BOOL need = YES;
    for (id obj in self.requestInterceptorObjectArray) {
        if ([obj respondsToSelector:@selector(needRequestWithRequest:)]) {
            need = [obj needRequestWithRequest:request];
            if (need) {
                break;
            }
        }
    }
    return need;
}


- (NSString *)requestMultipartData:(GHNetworkRequest *)request data:(NSData *)data progress:(void (^)(NSProgress *downloadProgress))progress complete:(GHNetworkResponseBlock)complete {
    __block NSURLSessionUploadTask *task = nil;
    
    if (GHNetworkConfigure.share.startReachability &&
        [[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] != AFNetworkReachabilityStatusReachableViaWWAN &&
        [[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] != AFNetworkReachabilityStatusReachableViaWiFi) {
        
        NSError *error = [NSError errorWithDomain:NSLocalizedString(@"There seems to be a glitch in the network, please try again later", nil) code:-1009 userInfo:nil];
        [self requestFinishedWithBlock:complete task:nil data:nil error:error];
        return nil;
    }

    if (![self needRequestInterceptor:request]) {
        if (GHNetworkConfigure.share.enableDebug) NSLog(@"该请求已经取消");
        return nil;
    }
    if (GHNetworkConfigure.share.enableDebug) [GHNetworkLogger logDebugInfoWithRequest:request];
    
    task = [self.sessionManager uploadTaskWithStreamedRequest:[request formDataRequest:data] progress:progress completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error && [response isKindOfClass:NSHTTPURLResponse.class]) {
            // 重写ERROR，重新code
            NSHTTPURLResponse *rsp = (NSHTTPURLResponse *)response;
            error = [NSError errorWithDomain:error.localizedDescription code:rsp.statusCode userInfo:error.userInfo];
        }
        [self.reqeustDictionary removeObjectForKey:@([task taskIdentifier])];
        [self requestFinishedWithBlock:complete task:task data:responseObject error:error];
    }];

    NSString *requestId = [[NSString alloc] initWithFormat:@"%@", @([task taskIdentifier])];
    self.reqeustDictionary[requestId] = task;
    [task resume];
    return requestId;
}

- (void)clearCache:(BOOL)isAsyc {
    [GHNetworkCache clearCache:GHNetworkConfigure.share.userToken isAsyc:isAsyc];
}

@end
