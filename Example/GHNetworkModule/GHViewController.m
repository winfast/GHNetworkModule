//
//  GHViewController.m
//  GHNetworkModule
//
//  Created by Qincc on 12/12/2020.
//  Copyright (c) 2020 Qincc. All rights reserved.
//

#import "GHViewController.h"
#import <GHNetworkModule/GHNetwork.h>


@interface GHViewController ()

@end

@implementation GHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // MARK: ⚙ 网络请求组件基础配置
#ifdef DEBUG
    GHNetworkConfigure.share.generalServer = @"https://test-openiot.gosund.com";
#else
    GHNetworkConfigure.share.generalServer = @"https://openiot.gosund.com";
#endif
    GHNetworkConfigure.share.enableDebug = YES;
    GHNetworkConfigure.share.useCache = NO; //不实用缓存
    
    GHNetworkConfigure.share.respondeSuccessKeys = @[@"err_code"];   /** 与后端约定的请求结果状态字段, 默认 code, status */
    GHNetworkConfigure.share.respondeHttpCodeKeys = @[@"http_code"];
    GHNetworkConfigure.share.respondeMsgKeys = @[@"msg"];       /** 与后端约定的请求结果消息字段集合, 默认 message, msg */
    GHNetworkConfigure.share.respondeDataKeys = @[@"data"];      /** 与后端约定的请求结果数据字段集合, 默认 data */
    GHNetworkConfigure.share.respondeSuccessCode = @"0";                  /** 与后端约定的请求成功code，默认为 200 */
    GHNetworkConfigure.share.respondeHttpCode = @"200";
    GHNetworkConfigure.share.startReachability = NO;
    GHNetworkConfigure.share.generalHeaders = @{
        @"platform":@"iphone",
        @"lang":[NSBundle.mainBundle objectForInfoDictionaryKey:@"GHLanguage"],
        @"appVersion":[NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
        @"os":@"iOS",
        @"osSystem":[[UIDevice currentDevice] systemVersion],
        @"requestType":@"app"
    };

    // 全局动态请求头参数设置，token，sign等
    GHNetworkConfigure.share.generalDynamicHeaders = ^NSDictionary<NSString *,NSString *> * _Nonnull(NSDictionary * _Nonnull parameters, BOOL requireToken) {
        NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithCapacity:1];
        [temp setValue:@"xxxxxxxxxx" forKey:@"Authorization"];
        return temp;
    };
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// TODO: 发送请求
- (IBAction)sendRequest:(id)sender {
        [self sendBasic1Request];
}

/**
 基础请求 1
 */
- (void)sendBasic1Request {
    GHNetworkRequest *request = [[GHNetworkRequest alloc] init];
    request.baseURL = nil; //
    request.methodPath = @"/v1.1/device/list";
    request.requestMethod = GHNetworkRequestMethodGET; //根据文档设置
    request.contenType = GHNetworkContenTypeJSON; //根据文档设置
    request.serializerType = GHNetworkSerializerTypeJSON; //根据文档设置
    request.normalParams = @{
        @"username":@"",
        @"password":@"",
        @"region_code":@"",
        @"phone_code":@"",
    };
    [GHNetworkModule.share sendRequest:request cacheComplete:nil networkComplete:^(GHNetworkResponse *response) {
        if (response.status == GHNetworkResponseStatusSuccess) {
            // 成功处理
        } else {
            // 失败处理
            NSLog(response.error.domain);
        }
        
        [GHNetworkModule.share cancelRequestWithRequestID:response.requestId];
    }];
}

- (void)sendBasic2Request {
    GHLoginRequest *request = GHLoginRequest.alloc.init;
    request.username = @"";
    request.password = @"";
    request.region_code = @"";
    request.phone_code = @(1);
    [GHNetworkModule.share sendRequest:request cacheComplete:nil networkComplete:^(GHNetworkResponse *response) {
        if (response.status == GHNetworkResponseStatusSuccess) {
            // 成功处理
        } else {
            // 失败处理
            NSLog(response.error.domain);
        }
        
        [GHNetworkModule.share cancelRequestWithRequestID:response.requestId];
    }];
}

@end


@implementation GHLoginRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.methodPath = @"/v1.1/obtain_jwt_auth/";
        self.requestMethod = GHNetworkRequestMethodPOST;
    }
    return self;
}

@end
