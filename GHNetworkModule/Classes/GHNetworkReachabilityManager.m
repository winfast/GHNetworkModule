//
//  GHNetworkReachabilityManager.m
//  GHNetworkModule
//
//  Created by Qincc on 2020/12/22.
//

#import "GHNetworkReachabilityManager.h"
#import "GHNetworkConfigure.h"


@implementation GHNetworkReachabilityManager

+ (void)startNetworkReachability:(void (^)(GHNetworkStatus status))statuBlock {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
        [manager startMonitoring];
        [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            GHNetworkStatus currStatus = status;
            !statuBlock ?: statuBlock(currStatus);
           // self.networkStatus = status;
        }];
    });
}

+ (void)startMonitoring {
    [AFNetworkReachabilityManager.sharedManager startMonitoring];
    GHNetworkConfigure.share.startReachability = YES;
}

+ (void)stopMonitoring {
    [AFNetworkReachabilityManager.sharedManager stopMonitoring];
    GHNetworkConfigure.share.startReachability = NO;
}

@end
