//
//  GHNetworkConfigure.h
//  GHNetworkModule
//
//  Created by Qincc on 2020/12/12.
//

#import <Foundation/Foundation.h>


@interface GHNetworkConfigure : NSObject

/// 是否使用YYCacle缓存数据， 如果使用YYCache缓存， key就是请求方法， value是JSON格式字符串
@property (nonatomic, getter=isUseCache) BOOL useCache;

/// 用户身份唯一标识符号，当userCache为YES的时候，必须设置这个值，用来保存用户请求的数据
@property (nonatomic, copy) NSString *userToken;

/// 证书路径
@property (nonatomic, copy) NSString *certificatePath;

/// 静态公共参数，设置好之后，不会变化
@property (nonatomic, copy) NSDictionary<NSString *, NSString *> *generalParameters;

/// 动态公共参数， 比如设置语言，等等功能
@property (nonatomic, copy) NSDictionary<NSString *, NSString *> * (^generalDynamicParameters)(void);

/** 静态公共请求头 */
@property (nonatomic, strong) NSDictionary *generalHeaders;

/** 动态公共请求头 parameters请求参数实体，参数用于加密依赖请求参数的需求*/
@property (nonatomic, copy) NSDictionary *(^generalDynamicHeaders)(NSDictionary *parameters, BOOL requireToken);

/** 所有请求统一回调方法 */
@property (nonatomic, copy) void (^responseUnifiedCallBack)(id response);

/** 服务器地址 */
@property (nonatomic, copy) NSString *generalServer;

/** 与后端约定的请求成功code，默认为 200 , 在公司服务器对应的字段是err_code*/
@property (nonatomic, copy) NSString *respondeSuccessCode;
@property (nonatomic, copy) NSString *respondeHttpCode;

/** 与后端约定的请求结果状态字段, 默认 code, status */
@property (nonatomic, copy) NSArray <NSString *> *respondeSuccessKeys;
@property (nonatomic, copy) NSArray <NSString *> *respondeHttpCodeKeys;

/** 与后端约定的请求结果数据字段集合, 默认 data */
@property (nonatomic, copy) NSArray <NSString *> *respondeDataKeys;

/** 与后端约定的请求结果消息字段集合, 默认 message, msg */
@property (nonatomic, copy) NSArray <NSString *> *respondeMsgKeys;

/** 是否启动网络监听 ， 默认不启动， 如果设置了YES， 在发送请求的时候判断了是否*/
@property (nonatomic) BOOL startReachability;

/** 是否为调试模式（默认 NO, 当为 YES 时，会输出 网络请求日志） */
@property (nonatomic, assign) BOOL enableDebug;

+ (instancetype)share;

@end

