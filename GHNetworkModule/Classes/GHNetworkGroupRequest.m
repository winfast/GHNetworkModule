//
//  GHNetworkGroupRequest.m
//  GHNetworkModule
//
//  Created by Qincc on 2020/12/14.
//

#import "GHNetworkGroupRequest.h"
#import "GHNetworkConstant.h"
#import "GHNetworkResponse.h"

@interface GHNetworkGroupRequest ()

@property (nonatomic, strong) dispatch_semaphore_t lock;
@property (nonatomic, assign) NSUInteger finishedCount;
@property (nonatomic, assign, getter=isFailed) BOOL failed;
@property (nonatomic,   copy) GHGroupResponseBlock completeBlock;

@end

@implementation GHNetworkGroupRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        _requestArray = [NSMutableArray new];
        _responseArray = [NSMutableArray new];
    }
    return self;
}

- (void)addRequest:(GHNetworkRequest *)request {
    [_requestArray addObject:request];
}

- (BOOL)onFinishedOneRequest:(GHNetworkRequest *)request response:(GHNetworkResponse *)responseObject {
    BOOL isFinished = NO;
    dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
    if (responseObject) {
        [_responseArray addObject:responseObject];
    }
    _failed |= (responseObject.status == GHNetworkResponseStatusError);
    
    _finishedCount ++;
    if (_finishedCount == _requestArray.count) {
        if (_completeBlock) {
            // 排序返回结果数组
            [_responseArray sortUsingComparator:^NSComparisonResult(GHNetworkResponse *obj1, GHNetworkResponse *obj2) {
                return obj1.requestId.integerValue > obj2.requestId.integerValue;
            }];
            _completeBlock(_responseArray.copy, !_failed);
        }
        [self cleanCallbackBlocks];
        isFinished = YES;
    }
    dispatch_semaphore_signal(_lock);
    return isFinished;
}

- (void)cleanCallbackBlocks {
    _completeBlock = nil;
}

// MARK: 懒加载
- (dispatch_semaphore_t)lock {
    if (!_lock) {
        _lock = dispatch_semaphore_create(1);
    }
    return _lock;
}

@end
