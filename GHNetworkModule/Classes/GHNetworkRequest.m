//
//  GHNetworkRequest.m
//  AFNetworking
//
//  Created by Qincc on 2020/12/12.
//

#import "GHNetworkRequest.h"
#import "GHNetworkConfigure.h"
#import <AFNetworking/AFNetworking.h>
#import "NSObject+GHNetworkModule.h"
#import <CommonCrypto/CommonDigest.h>

@interface GHNetworkRequest ()

@property (nonatomic, copy) NSString *requestMethodName;

@end

@implementation GHNetworkRequest

- (instancetype)init {
    if (self = [super init]) {
        self.timeoutInterval = 10;
        self.version = @"1.0.0";
        self.methodPath = @""; //给一个默认值。避免崩溃
    }
    return self;
}

- (NSURLRequest *)generateRequest {
    AFHTTPRequestSerializer *serializer = [self httpRequestSerializer];
    // 变更超时设置
    [serializer willChangeValueForKey:@"timeoutInterval"];
    [serializer setTimeoutInterval:self.timeoutInterval];
    [serializer didChangeValueForKey:@"timeoutInterval"];
    // 默认缓存策略
    [serializer setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    
    NSDictionary *parameters = [self generateRequestBody];
   // NSString *urlString = [self.baseURL stringByAppendingString:[@"" stringByAppendingPathComponent:self.methodPath]];
    NSString *urlString = [self.baseURL stringByAppendingString:self.methodPath];
    NSMutableURLRequest *request = [serializer requestWithMethod:[self httpMethod] URLString:urlString parameters:parameters error:NULL];
    // 请求头
    NSMutableDictionary *header = request.allHTTPHeaderFields.mutableCopy;
    if (header == nil) header = [[NSMutableDictionary alloc] init];
    // ContenType
    [header setValue:self.httpContenType forKey:@"Content-Type"];
    // 请求时插入的请求头
    [header addEntriesFromDictionary:self.header];
    // 静态公共请求头
    [header addEntriesFromDictionary:GHNetworkConfigure.share.generalHeaders];
    // 动态公共请求头
    if (GHNetworkConfigure.share.generalDynamicHeaders) {
        if ([self.baseURL isEqualToString:GHNetworkConfigure.share.generalServer]) {
            [header addEntriesFromDictionary:GHNetworkConfigure.share.generalDynamicHeaders(parameters, YES)];
        } else {
            [header addEntriesFromDictionary:GHNetworkConfigure.share.generalDynamicHeaders(parameters, NO)];
        }
    }
        
    request.allHTTPHeaderFields = header;
    
    return request.copy;
}

- (NSURLRequest *)formDataRequest:(NSData *)imageData imageKey:(NSString *)imageKey {
    AFHTTPRequestSerializer *serializer = [self httpRequestSerializer];
    // 变更超时设置
    [serializer willChangeValueForKey:@"timeoutInterval"];
    [serializer setTimeoutInterval:self.timeoutInterval];
    [serializer didChangeValueForKey:@"timeoutInterval"];
    // 默认缓存策略
    [serializer setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    
    NSDictionary *parameters = [self generateRequestBody];
   // NSString *urlString = [self.baseURL stringByAppendingString:[@"" stringByAppendingPathComponent:self.methodPath]];
    NSString *urlString = [self.baseURL stringByAppendingString:self.methodPath];
   // NSMutableURLRequest *request = [serializer requestWithMethod:[self httpMethod] URLString:urlString parameters:parameters error:NULL];
    
    NSMutableURLRequest *request = [serializer multipartFormRequestWithMethod:[self httpMethod] URLString:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSUInteger time = [NSDate.date timeIntervalSince1970] * 1000;
        NSString *fileName = [NSString stringWithFormat:@"%ld.jpg",time];
        [formData appendPartWithFileData:imageData name:imageKey fileName:fileName mimeType:@"image/*"];
    } error:NULL];
    
    // 请求头
    NSMutableDictionary *header = request.allHTTPHeaderFields.mutableCopy;
    if (header == nil) header = [[NSMutableDictionary alloc] init];
    // 请求时插入的请求头
    [header addEntriesFromDictionary:self.header];
    // 静态公共请求头
    [header addEntriesFromDictionary:GHNetworkConfigure.share.generalHeaders];
    // 动态公共请求头
    if (GHNetworkConfigure.share.generalDynamicHeaders) {
        if ([self.baseURL isEqualToString:GHNetworkConfigure.share.generalServer]) {
            [header addEntriesFromDictionary:GHNetworkConfigure.share.generalDynamicHeaders(parameters, YES)];
        } else {
            [header addEntriesFromDictionary:GHNetworkConfigure.share.generalDynamicHeaders(parameters, NO)];
        }
    }
    request.allHTTPHeaderFields = header;
    
    return request.copy;
}

/** 公共请求参数 @return 请求参数字典 */
- (NSDictionary *)generateRequestBody
{
    // 优先处理加密处理的请求参数
    NSMutableDictionary *temp = NSMutableDictionary.dictionary;
    NSMutableDictionary *mutableDic = self.encryptParams.mutableCopy;
    [mutableDic.allKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL * _Nonnull stop) {
        id value = mutableDic[key];
        NSError *error;
        
        switch (self.encryptType) {
            case GHEncryptTypeNone: {
                break;
            }
            case GHEncryptTypeBase64: {
                if (error == nil) {
                    NSString *valueString = nil;
                    if ([value isKindOfClass:NSString.class]) {
                        valueString = [value base64EncodedString:NSDataBase64Encoding64CharacterLineLength];
                    } else if ([value isKindOfClass:NSData.class]) {
                        NSString *currValueStr = [[NSString alloc] initWithData:(NSData *)value encoding:NSUTF8StringEncoding];
                        valueString = [currValueStr base64EncodedString:NSDataBase64Encoding64CharacterLineLength];;
                    } else {
                        NSString *currValueStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:value options:NSJSONWritingPrettyPrinted error:&error] encoding:NSUTF8StringEncoding];
                        valueString = [currValueStr base64EncodedString:NSDataBase64Encoding64CharacterLineLength];;
                    }
                    [mutableDic setValue:valueString forKey:key];
                } else {
                    NSLog(@"Serialization error.");
                }
            }
                break;
                
            case GHEncryptTypeMD5: {
                if (error == nil) {
                    NSString *valueString = nil;
                    if ([value isKindOfClass:NSString.class]) {
                        valueString = [value md5To32UppercaseString];
                    } else if ([value isKindOfClass:NSData.class]) {
                        valueString = [[[NSString alloc] initWithData:(NSData *)value encoding:NSUTF8StringEncoding] md5To32UppercaseString];
                    } else {
                        valueString = [[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:value options:NSJSONWritingPrettyPrinted error:&error] encoding:NSUTF8StringEncoding] md5To32UppercaseString];
                    }
                    [mutableDic setValue:valueString forKey:key];
                } else {
                    NSLog(@"Serialization error.");
                }
            }
                break;
        }
    }];
    [temp addEntriesFromDictionary:mutableDic];
    
    // 静态公共参数
    [temp addEntriesFromDictionary:GHNetworkConfigure.share.generalParameters];
    // 动态公共参数
    if (GHNetworkConfigure.share.generalDynamicParameters)
        [temp addEntriesFromDictionary:GHNetworkConfigure.share.generalDynamicParameters()];
    [temp addEntriesFromDictionary:self.normalParams];
    
    return temp.copy;
}

- (NSString *)httpMethod
{
    GHNetworkRequestMethod type = [self requestMethod];
    switch (type) {
        case GHNetworkRequestMethodGET:
            return @"GET";
        case GHNetworkRequestMethodPOST:
            return @"POST";
        case GHNetworkRequestMethodPUT:
            return @"PUT";
        case GHNetworkRequestMethodDELETE:
            return @"DELETE";
        case GHNetworkRequestMethodPATCH:
            return @"PATCH";
        default:
            break;
    }
    return @"GET";
}

- (NSString *)httpContenType {
    switch (self.contenType) {
        case GHNetworkContenTypeFormURLEncoded:
            return @"application/x-www-form-urlencoded";
        case GHNetworkContenTypeJSON:
            return @"application/json";
        case GHNetworkContenTypeFormData:
            return @"multipart/form-data";
        case GHNetworkContenTypeXML:
            return @"application/xml";
        default:
            break;
    }
    return @"application/x-www-form-urlencoded";
}

- (AFHTTPRequestSerializer *)httpRequestSerializer {
    switch (self.serializerType) {
        case GHNetworkSerializerTypeHTTP:
            return AFHTTPRequestSerializer.serializer;
        case GHNetworkSerializerTypeJSON:
            return AFJSONRequestSerializer.serializer;
        case GHNetworkSerializerTypePropertyList:
            return AFPropertyListRequestSerializer.serializer;
        default:
            break;
    }
    return AFHTTPRequestSerializer.serializer;
}

- (NSString *)requestMethodName
{
    return [self httpMethod];
}

- (NSString *)baseURL {
    if (!_baseURL) {
        _baseURL = GHNetworkConfigure.share.generalServer;
    }
    return _baseURL;
}



@end
