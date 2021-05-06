//
//  GHNetworkBaseRequest.m
//  GHome
//
//  Created by Qincc on 2020/12/14.
//

#import "GHNetworkBaseRequest.h"
#import <MJExtension/MJExtension.h>
//#import "GHUserInfo.h"

@implementation GHNetworkBaseRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        self.requestMethod = GHNetworkRequestMethodGET;
        self.contenType = GHNetworkContenTypeJSON;
        self.serializerType = GHNetworkSerializerTypeJSON;
//		if (GHUserInfo.share.api_server) {  //根据IP地址获取服务器地址 请求框架优先获取baseURL， 如果没有使用generalServer
//			self.baseURL = GHUserInfo.share.api_server;
//		}
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
