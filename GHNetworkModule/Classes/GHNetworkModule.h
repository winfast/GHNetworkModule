//
//  GHNetworkModule.h
//  GHNetworkModule
//
//  Created by Qincc on 2020/12/12.
//

#import <Foundation/Foundation.h>
#import "GHNetworkConstant.h"

@class GHNetworkResponse,GHNetworkRequest,AFHTTPSessionManager;


@interface GHNetworkModule : NSObject

@property (nonatomic, strong, readonly) NSMutableDictionary * reqeustDictionary;
@property (nonatomic, strong, readonly) AFHTTPSessionManager * sessionManager;
@property (nonatomic, strong) NSMutableArray * requestInterceptorObjectArray;
@property (nonatomic, strong) NSMutableArray * responseInterceptorObjectArray;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)share;

// MARK: - Nomal Request
/**
 @abstract  默认请求
 @param     request             请求实体类
 @param     cacheResult     缓存相应结果
 @param     result               响应结果
 @return    该请求对应的唯一 task id
 */
- (NSString *)sendRequest:(GHNetworkRequest *)request cacheComplete:(GHNetworkResponseBlock)cacheResult networkComplete:(GHNetworkResponseBlock)result;

/**
 @abstract  默认请求
 @param     requestBlock    请求配置 Block
 @param     cacheResult     缓存相应结果
 @param     result                  请求结果 Block
 @return    该请求对应的唯一 task id
 */
- (NSString *)sendRequestWithConfigBlock:(GHRequestConfigBlock)requestBlock cacheComplete:(GHNetworkResponseBlock)cacheResult networkComplete:(GHNetworkResponseBlock) result;

// MARK: - Upload Request
/**
 @abstract  上传请求
 @param     request              请求实体类
 @param     bodyData            上传数据
 @param     progress            上传进度回调
 @param     result                  响应结果
 @return    该请求对应的唯一 task id
 */
- (NSString *)sendUploadRequest:(GHNetworkRequest *)request formData:(NSData *)bodyData progress:(void (^)(NSProgress *uploadProgress))progress complete:(GHNetworkResponseBlock)result;

/**
 @abstract  上传请求
 @param     requestBlock    请求配置 Block
 @param     bodyData            上传数据
 @param     progress            上传进度回调
 @param     result                 响应结果
 @return    该请求对应的唯一 task id
 */
- (NSString *)sendUploadRequestWithConfigBlock:(GHRequestConfigBlock)requestBlock formData:(NSData *)bodyData progress:(void (^)(NSProgress *uploadProgress))progress complete:(GHNetworkResponseBlock)result;

// MARK: - Download Request
/**
 @abstract  下载请求
 @param     request             请求实体类
 @param     result                响应结果
 @param     destination     文件存储路径配置
 @param     progress           下载进度回调
 @return    该请求对应的唯一 task id
 */
- (NSString *)sendDownloadRequest:(GHNetworkRequest *)request destination:(NSURL * (^)(NSURL * _targetPath, NSURLResponse * _response))destination progress:(void (^)(NSProgress *downloadProgress))progress complete:(GHNetworkResponseBlock)result;

/**
 @abstract  下载请求
 @param     requestBlock     请求配置 Block
 @param     result                  请求结果 Block
 @param     destination       文件存储路径配置
 @param     progress             下载进度回调
 @return    该请求对应的唯一 task id
 */
- (NSString *)sendDownloadRequestWithConfigBlock:(GHRequestConfigBlock)requestBlock destination:(NSURL * (^)(NSURL * _targetPath, NSURLResponse * _response))destination progress:(void (^)(NSProgress *downloadProgress))progress complete:(GHNetworkResponseBlock)result;

// MARK: - Cancle Request
/**
 @abstract  单一取消请求
 @param     requestID 任务请求ID
 */
- (void)cancelRequestWithRequestID:(NSString *)requestID;

/**
 @abstract  批量取消请求
 @param     requestIDList 任务请求 ID 列表
 */
- (void)cancelRequestWithRequestIDList:(NSArray<NSString *> *)requestIDList;


/// 上传图片
/// @param request request请求
/// @param data 图片数据
/// @param progress 进度
/// @param imageKey data字段， 根据协议指定
/// @param complete 完成block
- (NSString *)requestMultipartData:(GHNetworkRequest *)request data:(NSData *)data imageKey:(NSString *)imageKey progress:(void (^)(NSProgress *downloadProgress))progress complete:(GHNetworkResponseBlock)complete;

- (void)clearCache:(BOOL)isAsyc;

@end

