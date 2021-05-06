//
//  GHNetworkConfigure.m
//  GHNetworkModule
//
//  Created by Qincc on 2020/12/12.
//

#import "GHNetworkConfigure.h"

@implementation GHNetworkConfigure

+ (instancetype)share {
    static dispatch_once_t onceToken;
    static GHNetworkConfigure *networkConfig;
    dispatch_once(&onceToken, ^{
        networkConfig = GHNetworkConfigure.alloc.init;
    });
    return networkConfig;;
}

- (instancetype)init {
    if (self = [super init]) {
        self.enableDebug = NO;
        self.respondeMsgKeys = @[@"meesagae",@"msg"];
        self.respondeDataKeys = @[@"data"];
        self.respondeSuccessKeys = @[@"err_code"];
        self.respondeHttpCodeKeys = @[@"http_code"];
    }
    return self;
}

- (NSString *)respondeSuccessCode {
    if (!_respondeSuccessCode) {
        _respondeSuccessCode = @"0";
    }
    return _respondeSuccessCode;
}

- (NSString *)respondeHttpCode {
    if (!_respondeHttpCode) {
        _respondeHttpCode = @"200";
    }
    return _respondeHttpCode;
}

- (NSString *)userToken {
    if (!_userToken) {
        _userToken = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    }
    return _userToken;
}

@end
