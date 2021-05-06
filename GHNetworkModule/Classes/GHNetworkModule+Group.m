//
//  GHNetworkModule+Group.m
//  GHNetworkModule
//
//  Created by Qincc on 2020/12/14.
//

#import "GHNetworkModule+Group.h"
#import "GHNetworkGroupRequest.h"
#import "GHNetworkRequest.h"
#import <objc/runtime.h>

@implementation GHNetworkModule (Group)

- (NSString *)sendGroupRequest:(GHGroupRequestConfigBlock)configBlock
                 cacheComplete:(GHGroupResponseBlock)cacheCompleteBlock
               networkComplete:(GHGroupResponseBlock)networkCompleteBlock {
    if (![self groupRequestDictionary]) {
        [self setGroupRequestDictionary:[[NSMutableDictionary alloc] init]];
    }
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    GHNetworkGroupRequest *groupRequest = [[GHNetworkGroupRequest alloc] init];
    configBlock(groupRequest);
    
    if (groupRequest.requestArray.count > 0) {
        if (networkCompleteBlock) {
            [groupRequest setValue:networkCompleteBlock forKey:@"_completeBlock"];
        }
        
        [groupRequest.responseArray removeAllObjects];
        for (GHNetworkRequest *request in groupRequest.requestArray) {
            NSString *taskID = [self sendRequest:request cacheComplete:nil networkComplete:^(GHNetworkResponse * response) {
                if ([groupRequest onFinishedOneRequest:request response:response]) {
                    NSLog(@"finish");
                }
            }];
            if (taskID) {
                [tempArray addObject:taskID];
            }
        }
        NSString *uuid = [[NSUUID UUID].UUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""];
        [self groupRequestDictionary][uuid] = tempArray.copy;
        return uuid;
    }
    return nil;
}

- (void)cancelGroupRequest:(NSString *)taskID {
    NSArray *group = [self groupRequestDictionary][taskID];
    for (NSString *tid in group) {
        [self cancelRequestWithRequestID:tid];
    }
}

- (NSMutableDictionary *)groupRequestDictionary {
    return objc_getAssociatedObject(self, @selector(groupRequestDictionary));
}

- (void)setGroupRequestDictionary:(NSMutableDictionary *)mutableDictionary {
    objc_setAssociatedObject(self, @selector(groupRequestDictionary), mutableDictionary, OBJC_ASSOCIATION_RETAIN);
}

@end
