//
//  GHNetworkReachabilityManager.h
//  GHNetworkModule
//
//  Created by Qincc on 2020/12/22.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

typedef enum : NSUInteger {
    GHNetworkStatusUnknow = AFNetworkReachabilityStatusUnknown,
    GHNetworkStatusNotReachable = AFNetworkReachabilityStatusNotReachable,
    GHNetworkStatusReachableViaWWAN = AFNetworkReachabilityStatusReachableViaWWAN,
    GHNetworkStatusReachableViaWiFi = AFNetworkReachabilityStatusReachableViaWiFi,
} GHNetworkStatus;

@interface GHNetworkReachabilityManager : NSObject

+ (void)startNetworkReachability:(void (^)(GHNetworkStatus status))statuBlock;

+ (void)startMonitoring;
+ (void)stopMonitoring;

@end

