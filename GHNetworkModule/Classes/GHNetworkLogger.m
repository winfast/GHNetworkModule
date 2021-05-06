//
//  GHNetWorkLogger.m
//  GHNetworkModule
//
//  Created by Qincc on 2020/12/12.
//

#import "GHNetworkLogger.h"
#import "GHNetworkConstant.h"
#import "GHNetworkRequest.h"
#import "GHNetworkConfigure.h"
#import "NSObject+GHNetworkModule.h"


@implementation GHNetworkLogger

/**
 输出签名
 */
+ (void)logSignInfoWithString:(NSString *)sign {
    NSMutableString *logString = [NSMutableString stringWithString:@"\n-----------------------------------签名参数-----------------------------------\n"];
    [logString appendFormat:@"%@", sign];
    [logString appendFormat:@"\n-----------------------------------签名参数-----------------------------------\n"];
    NSLog(@"%@", logString);
}

/** 请求参数 */
+ (void)logDebugInfoWithRequest:(GHNetworkRequest *)request {
    NSMutableString *logString = [NSMutableString stringWithString:@"\n-----------------------------------执行请求-----------------------------------\n"];
    [logString appendFormat:@"HTTP URL:\t\t%@\n", [request.baseURL stringByAppendingString:[@"" stringByAppendingPathComponent:request.methodPath]]];
    [logString appendFormat:@"Method:\t\t\t%@\n", [request requestMethodName]];
    [logString appendFormat:@"Version:\t\t%@\n",  request.version];
    NSMutableDictionary *parameters = NSMutableDictionary.dictionary;
    [parameters addEntriesFromDictionary:request.normalParams];
    [parameters addEntriesFromDictionary:request.encryptParams];
    [parameters addEntriesFromDictionary:GHNetworkConfigure.share.generalParameters];
    if (GHNetworkConfigure.share.generalDynamicParameters) {
        [parameters addEntriesFromDictionary:GHNetworkConfigure.share.generalDynamicParameters()];
    }
    [logString appendFormat:@"Params:\n%@", parameters];
    [logString appendFormat:@"\n-----------------------------------------------------------------------------\n\n"];
    NSLog(@"%@", logString);
}

/**  响应数据输出 */
+ (void)logDebugInfoWithTask:(NSURLSessionTask *)sessionTask data:(NSData *)data error:(NSError *)error{
    NSMutableString *logString = [NSMutableString stringWithString:@"\n-----------------------------------请求结果------------------------------------\n"];
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)sessionTask.response;
    NSURLRequest *request = sessionTask.originalRequest;
    [logString appendFormat:@"HTTP URL:\t\t%@\n", request.URL];
    [logString appendFormat:@"HTTP Header:\n%@\n", request.allHTTPHeaderFields];
    NSString *jsonString = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
    [logString appendFormat:@"HTTP Body:\t\t%@\n", jsonString.stringByRemovingPercentEncoding];
    [logString appendFormat:@"Status:\t\t\t%ld\t(%@)\n", (long)response.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode]];
    [logString appendFormat:@"JSONData:\n%@\n\n", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    if (error) {
        [logString appendFormat:@"ErrorDomain:\t\t\t\t\t\t%@\n", error.domain];
        [logString appendFormat:@"ErrorDomainCode:\t\t\t\t\t%ld\n", (long)error.code];
        [logString appendFormat:@"ErrorLocalizedDescription:\t\t\t%@\n", error.localizedDescription];
        [logString appendFormat:@"ErrorLocalizedFailureReason:\t\t%@\n", error.localizedFailureReason];
        [logString appendFormat:@"ErrorLocalizedRecoverySuggestion:\t%@", error.localizedRecoverySuggestion];
    }
    [logString appendFormat:@"\n-----------------------------------------------------------------------------\n\n"];
    NSLog(@"%@", logString);
}

@end
