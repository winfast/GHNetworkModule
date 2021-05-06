# GHNetworkModule

[![CI Status](https://img.shields.io/travis/Qincc/GHNetworkModule.svg?style=flat)](https://travis-ci.org/Qincc/GHNetworkModule)
[![Version](https://img.shields.io/cocoapods/v/GHNetworkModule.svg?style=flat)](https://cocoapods.org/pods/GHNetworkModule)
[![License](https://img.shields.io/cocoapods/l/GHNetworkModule.svg?style=flat)](https://cocoapods.org/pods/GHNetworkModule)
[![Platform](https://img.shields.io/cocoapods/p/GHNetworkModule.svg?style=flat)](https://cocoapods.org/pods/GHNetworkModule)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

GHNetworkModule is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'GHNetworkModule'
```

## Author

Qincc, 418891087@qq.com

## License

GHNetworkModule is available under the MIT license. See the LICENSE file for more info.

## Example

```Objective-C
1. 配置HTTPS请求环境(可以复制下面的代码)
    #ifdef DEBUG
    GHNetworkConfigure.share.generalServer = @"https://test-openiot.gosund.com";
#else
	GHNetworkConfigure.share.generalServer = @"https://openiot.gosund.com";
#endif
    GHNetworkConfigure.share.enableDebug = YES; //开启日志
    GHNetworkConfigure.share.useCache = NO; //不需要缓存
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
//    // 全局静态请求头参数设置
//    GPNetworkConfigure.shareInstance.generalHeaders = ({
//        NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
//        [temp setValue:@"iOS" forKey:@"platform"];
//        [temp setValue:[NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleShortVersionString"] forKey:@"version"];
//        [temp setValue:@"App Store" forKey:@"channel"];
//        temp;
//    });
//
//
//    // 全局动态请求头参数设置，token，sign等
	GHNetworkConfigure.share.generalDynamicHeaders = ^NSDictionary<NSString *,NSString *> * _Nonnull(NSDictionary * _Nonnull parameters) {
        NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithCapacity:1];
		[temp setValue:GHUserInfo.share.Authorization forKey:@"Authorization"];  //登陆后根据Token生成校验字段
        return temp;
    };
2. HTTPS请求Demo
   目前有两种方式：
   （1）方式1
      GHNetworkRequest *requset = GHNetworkRequst.alloc.init;
      request.baseURL = @"";  //根据IP所在的区域获取当前区域的服务器地址；
      request.methodPath = @"/v1.1/device/list";
      request.requestMethod = GHNetworkRequestMethodGET;
       request.contenType = GHNetworkContenTypeJSON;
       request.serializerType = GHNetworkSerializerTypeJSON;
      request.normalParams = @{
      @"password":@"",
      @"userName":@""
      };
     [GHNetworkModule.share sendRequest:requset cacheComplete:nil networkComplete:^(GHNetworkResponse *response) {
					//数据处理
					
					[GHNetworkModule.share cancelRequestWithRequestID:response.requestId]
				}];
   （2）方式2
       定义一个类
       头文件如下
       @interface GHNetworkBaseRequest : GHNetworkRequest
        @end
         
        实现文件如下
        #import "GHNetworkBaseRequest.h"
        #import <MJExtension/MJExtension.h>//使用这个框架的目的是将请求模型化
       @implementation GHNetworkBaseRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        self.requestMethod = GHNetworkRequestMethodGET;
        self.contenType = GHNetworkContenTypeJSON;
        self.serializerType = GHNetworkSerializerTypeJSON;
		if (GHUserInfo.share.api_server) {
			self.baseURL = GHUserInfo.share.api_server;
		}
    }
    return self;
}

static NSArray *_ignores; // 忽略基类所有属性
+ (NSArray *)mj_ignoredPropertyNames {
    if (_ignores == nil) {
        unsigned int count;
        objc_property_t *properties = class_copyPropertyList(GHNetworkRequest.class, &count);
        NSMutableArray *temp = [NSMutableArray array];
        for (int i = 0; i < count; i++) {
            objc_property_t property = properties[i];
            const char *cName = property_getName(property);
            NSString *name = [NSString stringWithCString:cName encoding:NSUTF8StringEncoding];
            [temp addObject:name];
        }
        _ignores = temp.copy;
    }
    return _ignores;
}

- (NSDictionary *)normalParams {
    return self.mj_keyValues;
}

@end

//登陆请求
@interface GHLoginRequest: GHNetworkBaseRequest

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *passWord;

@end
@implementation GHLoginRequest 
- (instancetype)init {
	self = [super init];
	if (self) {
		self.requestMethod = GHNetworkRequestMethodGET;
		self.methodPath = @"";
	}
	return self;
}
@end

GHLoginRequset *request = GHLoginRequest.alloc.init;
request.userName = @"";
request.password = @"";

[GHNetworkModule.share sendRequest:request cacheComplete:nil networkComplete:^(GHNetworkResponse *response) {
					//数据处理
					
					[GHNetworkModule.share cancelRequestWithRequestID:response.requestId]
				}];


```