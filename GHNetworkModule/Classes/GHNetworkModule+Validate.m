//
//  GHNetworkModule+Validate.m
//  GHNetworkModule
//
//  Created by Qincc on 2021/1/18.
//

#import "GHNetworkModule+Validate.h"

@implementation GHNetworkModule (Validate)

+ (void)registerResponseInterceptor:(nonnull Class)cls {
    if (![cls conformsToProtocol:@protocol(GHResponseInterceptorProtocol)]) {
        return;
    }
    
    [GHNetworkModule unregisterResponseInterceptor:cls];
    
    GHNetworkModule *share = [GHNetworkModule share];
    [share.responseInterceptorObjectArray addObject:[cls new]];
}

+ (void)unregisterResponseInterceptor:(nonnull Class)cls{
    GHNetworkModule *share = [GHNetworkModule share];
    
    for (id obj in share.responseInterceptorObjectArray) {
        if ([obj isKindOfClass:[cls class]]) {
            [share.responseInterceptorObjectArray removeObject:obj];
            break;
        }
    }
}

+ (void)registerRequestInterceptor:(nonnull Class)cls{
    if (![cls conformsToProtocol:@protocol(GHResponseInterceptorProtocol)]) {
        return;
    }
    
    [GHNetworkModule unregisterRequestInterceptor:cls];
    
    GHNetworkModule *share = [GHNetworkModule share];
    [share.requestInterceptorObjectArray addObject:[cls new]];
}

+ (void)unregisterRequestInterceptor:(nonnull Class)cls{
    GHNetworkModule *share = [GHNetworkModule share];
    for (id obj in share.requestInterceptorObjectArray) {
        if ([obj isKindOfClass:[cls class]]) {
            [share.requestInterceptorObjectArray removeObject:obj];
            break;
        }
    }
}

@end
