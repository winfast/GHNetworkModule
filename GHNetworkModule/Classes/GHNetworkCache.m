//
//  GHNetworkCache.m
//  GHNetworkModule
//
//  Created by Qincc on 2020/12/12.
//

#import "GHNetworkCache.h"

static YYCache *gh_cache;

@implementation GHNetworkCache

+ (void)resetCacheName:(NSString *)name {
    if (gh_cache) {
        [gh_cache removeAllObjects];
    }
    gh_cache = [[YYCache alloc] initWithName:name];
}

+ (void)syncWriteCache:(NSString *)userToken key:(NSString *)key value:(id)value {
   // YYCache *cache = [YYCache cacheWithName:userToken];
    [gh_cache setObject:value forKey:key];
}

+ (void)asycWriteCache:(NSString *)userToken key:(NSString *)key value:(id)value completeBlock:(void(^)(void))completeBlock {
  //  YYCache *cache = [YYCache cacheWithName:userToken];
    [gh_cache setObject:value forKey:key withBlock:^{
        !completeBlock ?: completeBlock();
    }];
}

+ (id)syncReadCache:(NSString *)userToken key:(NSString *)key {
  //  YYCache *cache = [YYCache cacheWithName:userToken];
    if ([gh_cache containsObjectForKey:key]) {
        return [gh_cache objectForKey:key];
    }
    return nil;
}

+ (void)asycReadCache:(NSString *)userToken key:(NSString *)currKey completeBlock:(void(^)(id))completeBlock; {
   // YYCache *cache = [YYCache cacheWithName:userToken];
    if ([gh_cache containsObjectForKey:currKey]) {
        [gh_cache objectForKey:currKey withBlock:^(NSString * _Nonnull key, id<NSCoding>  _Nonnull object) {
            if ([key isEqualToString:currKey]) {
                !completeBlock ?: completeBlock(object);
            }
        }];
    }
}

+ (void)clearCache:(NSString *)userToken isAsyc:(BOOL)isAsyc; {
   // YYCache *cache = [YYCache cacheWithName:userToken];
    if (isAsyc) {
        [gh_cache removeAllObjectsWithBlock:^{
        }];
    } else {
        [gh_cache removeAllObjects];
    }
}

//+ (void)syncRemoveCache:(NSString *)userToken {
//    YYCache *cache = [YYCache cacheWithName:userToken];
//    [cache removeAllObjects];
//}
//
//+ (void)syncRemoveCache:(NSString *)userToken key:(NSString *)key {
//    YYCache *cache = [YYCache cacheWithName:userToken];
//    [cache removeObjectForKey:key withBlock:^(NSString * _Nonnull key) {
//
//    }];
//}

@end
