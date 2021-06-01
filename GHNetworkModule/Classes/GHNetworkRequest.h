//
//  GHNetworkRequest.h
//  AFNetworking
//
//  Created by Qincc on 2020/12/12.
//

#import <Foundation/Foundation.h>
#import "GHNetworkConstant.h"


@interface GHNetworkRequest : NSObject

/// 请求BaseURL， 如果设置了该参数， 优先获取该参数
@property (nonatomic, copy) NSString *baseURL;

/// 请求路径 @"/device/list"
@property (nonatomic, copy) NSString *methodPath;

/// 请求头字典  默认为nil
@property (nonatomic, copy) NSDictionary *header;

/// 请求参数，不需要加密的参数
@property (nonatomic, copy) NSDictionary *normalParams;

///  参数加密类型， 默认不加密
@property (nonatomic) GHEncryptType encryptType;
/** 请求参数，加密参数 不指定加密类型时，同normalParams混用 */
@property (nonatomic, strong) NSDictionary *encryptParams;

/// 请求方式， 猎魔人使用GHNetworkRequestMethodGET
@property (nonatomic) GHNetworkRequestMethod requestMethod;

/// 请求方法的名称
@property (nonatomic, copy, readonly) NSString *requestMethodName;

/** 标识MIME类型
    默认 application/x-www-form-urlencoded - KLNetworkContenTypeFormURLEncoded
 */
@property (nonatomic, assign) GHNetworkContenType contenType;
/** 标识序列化类型
    默认 KLNetworkSerializerTypeHTTP - AFHTTPRequestSerializer
 */
@property (nonatomic, assign) GHNetworkSerializerType serializerType;

/** 请求超时时间 默认 30s */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/** api 版本号，默认 1.0.0*/
@property (nonatomic, copy) NSString *version;

/** 生成请求实体 @return 请求对象*/
- (NSURLRequest *)generateRequest;

/** 生成上传实体 @return 请求对象*/
- (NSURLRequest *)formDataRequest:(NSData *)imageData imageKey:(NSString *)imageKey;

@end

