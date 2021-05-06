//
//  GHNetworkModule+Group.h
//  GHNetworkModule
//
//  Created by Qincc on 2020/12/14.
//

#import <GHNetworkModule/GHNetworkModule.h>
#import "GHNetworkConstant.h"

@interface GHNetworkModule (Group)

// 不适用上传/下载请求  目前不支持数据缓存
- (NSString *)sendGroupRequest:(GHGroupRequestConfigBlock)configBlock
                 cacheComplete:(GHGroupResponseBlock)cacheCompleteBlock
               networkComplete:(GHGroupResponseBlock)networkCompleteBlock;

- (void)cancelGroupRequest:(NSString *)taskID;

@end

