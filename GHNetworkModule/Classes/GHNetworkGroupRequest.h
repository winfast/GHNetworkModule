//
//  GHNetworkGroupRequest.h
//  GHNetworkModule
//
//  Created by Qincc on 2020/12/14.
//

#import <Foundation/Foundation.h>

@class GHNetworkRequest, GHNetworkResponse;

@interface GHNetworkGroupRequest : NSObject

@property (nonatomic, strong, readonly) NSMutableArray <GHNetworkRequest *> *requestArray;
@property (nonatomic, strong, readonly) NSMutableArray <GHNetworkResponse *> *responseArray;

- (void)addRequest:(GHNetworkRequest *)request;
- (BOOL)onFinishedOneRequest:(GHNetworkRequest *)request response:(GHNetworkResponse *)responseObject;

@end
