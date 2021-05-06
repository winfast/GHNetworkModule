//
//  GHNetWorkLogger.h
//  GHNetworkModule
//
//  Created by Qincc on 2020/12/12.
//

#import <Foundation/Foundation.h>

@class GHNetworkRequest;

@interface GHNetworkLogger : NSObject

/** 输出签名 */
+ (void)logSignInfoWithString:(NSString *)sign;
/** 请求参数 */
+ (void)logDebugInfoWithRequest:(GHNetworkRequest *)request;
/** 响应数据输出 */
+ (void)logDebugInfoWithTask:(NSURLSessionTask *)sessionTask data:(NSData *)data error:(NSError *)error;

@end

