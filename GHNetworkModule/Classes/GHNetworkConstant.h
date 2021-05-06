//
//  GHNetworkConstant.h
//  GHNetworkModule
//
//  Created by Qincc on 2020/12/12.
//

#ifndef GHNetworkConstant_h
#define GHNetworkConstant_h


#import "GHRequestInterceptorProtocol.h"
#import "GHResponseInterceptorProtocol.h"

@class GHNetworkResponse,GHNetworkRequest,GHNetworkGroupRequest/*GHNetworkChainRequest*/;

typedef NS_ENUM (NSUInteger, GHNetworkRequestMethod){
    GHNetworkRequestMethodGET = 0,
    GHNetworkRequestMethodPOST,
    GHNetworkRequestMethodPUT,
    GHNetworkRequestMethodDELETE,
    GHNetworkRequestMethodPATCH
};

typedef NS_ENUM (NSUInteger, GHNetworkResponseStatus){
    GHNetworkResponseStatusError = 0,
    GHNetworkResponseStatusSuccess
};

typedef NS_ENUM (NSUInteger, GHEncryptType){
    GHEncryptTypeNone = 0,
    GHEncryptTypeBase64 = 1,
    GHEncryptTypeMD5            // 32位加密&大写字母
};

typedef NS_ENUM (NSUInteger, GHNetworkContenType){
    GHNetworkContenTypeFormURLEncoded = 0,
    GHNetworkContenTypeJSON           = 1,
    GHNetworkContenTypeFormData       = 2,
    GHNetworkContenTypeXML            = 3
};

typedef NS_ENUM (NSUInteger, GHNetworkSerializerType){
    GHNetworkSerializerTypeHTTP         = 0,
    GHNetworkSerializerTypeJSON         = 1,
    GHNetworkSerializerTypePropertyList = 2
};

// 响应配置 Block
typedef void (^GHNetworkResponseBlock)(GHNetworkResponse * response);
typedef void (^GHGroupResponseBlock)(NSArray<GHNetworkResponse *> * responseObjects, BOOL isSuccess);
typedef void (^NextBlock)(GHNetworkRequest * request, GHNetworkResponse * responseObject, BOOL * isSent);

// 请求配置 Block
typedef void (^GHRequestConfigBlock)(GHNetworkRequest * request);
typedef void (^GHGroupRequestConfigBlock)(GHNetworkGroupRequest * groupRequest);
//typedef void (^ChainRequestConfigBlock)(GHNetworkChainRequest * chainRequest);


#endif /* GHNetworkConstant_h */
