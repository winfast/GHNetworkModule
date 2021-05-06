//
//  GHNetworkResponse.h
//  GHNetworkModule
//
//  Created by Qincc on 2020/12/12.
//

#import <Foundation/Foundation.h>
#import "GHNetworkConstant.h"

@interface GHNetworkResponse : NSObject

/** 服务器返回状态 */
@property (nonatomic, assign, readonly) GHNetworkResponseStatus status;
/** 服务器返回经处理的数据 */
@property (nonatomic, copy  , readonly) id JSONObject;
/** 便捷取值，JSONObject下如果有data字段 */
@property (nonatomic, copy  , readonly) id data;
/** 服务器返回原始数据 */
@property (nonatomic, copy  , readonly) NSData *rawData;
/** 网络请求异常信息实体 */
@property (nonatomic, copy  , readonly) NSError *error;
/** 服务器返回状态码 */
@property (nonatomic, assign, readonly) NSInteger statueCode;
/** 服务器返回HTTP状态码 */
@property (nonatomic, assign, readonly) NSInteger httpCode;
/** 服务器返回消息 */
@property (nonatomic, copy  , readonly) NSString *message;
/** 服务器返回请求ID */
@property (nonatomic, copy  , readonly) NSString *requestId;
/** 当前请求实体 */
@property (nonatomic, copy  , readonly) NSURLRequest *request;

- ( instancetype)initWithRequestId:(NSNumber *)requestId
                           request:( NSURLRequest *)request
                      responseData:( NSData *)responseData
                            status:(GHNetworkResponseStatus)status;

- ( instancetype)initWithRequestId:(NSNumber *)requestId
                           request:(NSURLRequest *)request
                      responseData:(NSData *)responseData
                             error:(NSError *)error;


/// 缓存返回的数据格式
/// @param responseData 缓存保存的数据
- (instancetype)initWithCacheResponse:(NSDictionary *)responseData;

@end

