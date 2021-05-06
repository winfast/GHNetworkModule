//
//  GHNetworkResponse.m
//  GHNetworkModule
//
//  Created by Qincc on 2020/12/12.
//

#import "GHNetworkResponse.h"
#import "GHNetworkConfigure.h"
#import "NSObject+GHNetworkModule.h"
#import "GHNetworkCache.h"

@interface GHNetworkResponse ()

/** 服务器返回状态 */
@property (nonatomic, assign) GHNetworkResponseStatus status;
/** 服务器返回经处理的数据 */
@property (nonatomic, copy  ) id JSONObject;
/** 便捷取值，JSONObject下如果有data字段 */
@property (nonatomic, copy  ) id data;
/** 服务器返回原始数据 */
@property (nonatomic, copy  ) NSData *rawData;
/** 网络请求异常信息实体 */
@property (nonatomic, copy) NSError *error;
/** 服务器返回状态码 */
@property (nonatomic, assign) NSInteger statueCode;
/** 服务器返回HTTP状态码 */
@property (nonatomic, assign) NSInteger httpCode;
/** 服务器返回消息 */
@property (nonatomic, copy  ) NSString *message;
/** 服务器返回请求ID */
@property (nonatomic, copy  ) NSString *requestId;
/** 当前请求实体 */
@property (nonatomic, copy  ) NSURLRequest *request;

@end


@implementation GHNetworkResponse

- ( instancetype)initWithRequestId:( NSNumber *)requestId
                           request:(NSURLRequest *)request
                      responseData:(NSData *)responseData
                            status:(GHNetworkResponseStatus)status {
    self = [super init];
    if (self)
    {
        //需要根据服务器的配置修改
        self.requestId = requestId.stringValue;
        self.request = request;
        self.rawData = responseData;
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL];
        self.JSONObject = dic;
        // 服务器返回字段不确定，根据实际情况进行调整
        __block id value = nil;
        [GHNetworkConfigure.share.respondeSuccessKeys enumerateObjectsUsingBlock:^(id  _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
            value = [dic valueForKey:key];
            if (value) *stop = YES;         // 命中即停止
        }];
        id code = value;
        self.statueCode = [code integerValue];
        
        value = nil;
        [GHNetworkConfigure.share.respondeHttpCodeKeys enumerateObjectsUsingBlock:^(id  _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
            value = [dic valueForKey:key];
            if (value) *stop = YES;         // 命中即停止
        }];
        id httpCode = value;
        self.httpCode = [httpCode integerValue];
        
        value = nil;
        [GHNetworkConfigure.share.respondeDataKeys enumerateObjectsUsingBlock:^(id  _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
            value = [dic valueForKey:key];
            if (value) *stop = YES;         // 命中即停止
        }];
        self.data = value;
        
        value = nil;
        [GHNetworkConfigure.share.respondeMsgKeys enumerateObjectsUsingBlock:^(id  _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
            value = [dic valueForKey:key];
            if (value) *stop = YES;         // 命中即停止
        }];
        self.message = value;
        
        if (self.statueCode == GHNetworkConfigure.share.respondeSuccessCode.integerValue && self.httpCode == GHNetworkConfigure.share.respondeHttpCode.intValue) {
            self.status = GHNetworkResponseStatusSuccess;
        } else {
            self.status = GHNetworkResponseStatusError;
            NSError *error = [NSError errorWithDomain:self.message ? : @"" code:self.statueCode userInfo:nil];
            self.error = error;
        }
        
        if (GHNetworkConfigure.share.responseUnifiedCallBack) {
            GHNetworkConfigure.share.responseUnifiedCallBack(self.JSONObject);
        }
    }
    return self;
}

- ( instancetype)initWithRequestId:(NSNumber *)requestId
                           request:(NSURLRequest *)request
                      responseData:(NSData *)responseData
                             error:(NSError *)error {
    self = [super init];
    if (self)
    {
        self.status = GHNetworkResponseStatusError;
        self.requestId = requestId.stringValue;
        self.request = request;
        self.rawData = responseData;
        self.JSONObject = error.localizedDescription;
        self.statueCode = error.code;
        self.error = error;
        
        if (responseData) {
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL];
            if (responseDict && [responseDict isKindOfClass:NSDictionary.class]) {
                __block NSNumber *value = nil;  //获取错误编码
                [GHNetworkConfigure.share.respondeSuccessKeys enumerateObjectsUsingBlock:^(id  _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
                    value = [responseDict valueForKey:key];
                    if (value) *stop = YES;         // 命中即停止
                }];
                
                __block NSString *message = nil;  //获取提示消息
                [GHNetworkConfigure.share.respondeMsgKeys enumerateObjectsUsingBlock:^(id  _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
                    message = [responseDict valueForKey:key];
                    if (value) *stop = YES;         // 命中即停止
                }];
                self.error = [[NSError alloc] initWithDomain:message code:value.integerValue userInfo:nil];
                
            } else {
                self.error = error;
            }
        } else {
            self.error = error;
        }
        
        if ([self.error.domain isEqualToString:NSURLErrorDomain] || self.error.code == -1001) {
            self.error = [NSError errorWithDomain:NSLocalizedString(@"There seems to be a glitch in the network, please try again later", nil) code:self.error.code userInfo:self.error.userInfo];
        }
        
        if (GHNetworkConfigure.share.responseUnifiedCallBack) {
            GHNetworkConfigure.share.responseUnifiedCallBack(error);
        }
    }
    return self;
}

- (instancetype)initWithCacheResponse:(NSDictionary *)responseData {
    self = [super init];
    if (self) {
        self.status = GHNetworkResponseStatusSuccess;
        self.rawData = [responseData toJsonData];
        self.JSONObject = responseData;
        self.statueCode = 200;
        self.httpCode = 0;
        
        __block id value = nil;
        [GHNetworkConfigure.share.respondeDataKeys enumerateObjectsUsingBlock:^(id  _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
            value = [responseData valueForKey:key];
            if (value) *stop = YES;         // 命中即停止
        }];
        self.data = value;
    }
    return self;
}

@end
