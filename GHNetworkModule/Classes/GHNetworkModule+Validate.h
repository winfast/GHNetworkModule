//
//  GHNetworkModule+Validate.h
//  GHNetworkModule
//
//  Created by Qincc on 2021/1/18.
//

#import <GHNetworkModule/GHNetworkModule.h>

NS_ASSUME_NONNULL_BEGIN

@interface GHNetworkModule (Validate)

/**
 请求前的拦截器
 
 @param cls 实现 KLRequestInterceptorProtocol 协议的 实体类
 可以在该实体类中做请求前的处理
 */
+ (void)registerRequestInterceptor:(nonnull Class)cls;
+ (void)unregisterRequestInterceptor:(nonnull Class)cls;

/**
 返回数据前的拦截器
 
 @param cls 实现 ResponseInterceptorProtocol 协议的 实体类
 可以在该实体类中做统一的数据验证
 */
+ (void)registerResponseInterceptor:(nonnull Class)cls;
+ (void)unregisterResponseInterceptor:(nonnull Class)cls;


@end

NS_ASSUME_NONNULL_END
