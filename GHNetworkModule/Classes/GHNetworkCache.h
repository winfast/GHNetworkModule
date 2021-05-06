//
//  GHNetworkCache.h
//  GHNetworkModule
//
//  Created by Qincc on 2020/12/12.
//

#import <Foundation/Foundation.h>
#import <YYCache/YYCache.h>

@interface GHNetworkCache : NSObject

+ (void)resetCacheName:(NSString *)name;

+ (void)syncWriteCache:(NSString *)userToken key:(NSString *)key value:(id)value;

+ (void)asycWriteCache:(NSString *)userToken key:(NSString *)key value:(id)value completeBlock:(void(^)(void))completeBlock;

+ (id)syncReadCache:(NSString *)userToken key:(NSString *)key;

+ (void)asycReadCache:(NSString *)userToken key:(NSString *)currKey completeBlock:(void(^)(id))completeBlock;

+ (void)clearCache:(NSString *)userToken isAsyc:(BOOL)isAsyc;

//+ (void)syncRemoveCache:(NSString *)userToken;
//
//+ (void)syncRemoveCache:(NSString *)userToken key:(NSString *)key;

@end
