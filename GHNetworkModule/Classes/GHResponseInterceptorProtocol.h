//
//  KLResponseInterceptorProtocol.h
//  KLNetworkModule
//
//  Created by kalan on 2018/1/4.
//  Copyright © 2018年 kalan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GHNetworkResponse;

/** 网络响应返回前的拦截协议 */
@protocol GHResponseInterceptorProtocol <NSObject>

- (void)validatorResponse:(GHNetworkResponse *)rsp;

@end
