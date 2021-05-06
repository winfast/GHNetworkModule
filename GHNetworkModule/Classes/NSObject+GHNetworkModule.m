//
//  NSString+GHNetworkModule.m
//  GHNetworkModule
//
//  Created by Qincc on 2020/12/12.
//

#import "NSObject+GHNetworkModule.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (GHNetworkModule)

- (NSString *)base64EncodedString:(NSDataBase64EncodingOptions)options {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64EncodedStringWithOptions:options];
}

- (NSString *)base64DecodedString:(NSDataBase64DecodingOptions)options {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:self options:options];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSString *)md5To32UppercaseString {
    const char *cStr = [self UTF8String];         // 先转为UTF_8编码的字符串
    unsigned char digest[CC_MD5_DIGEST_LENGTH];     // 设置一个接受字符数组
    CC_MD5( cStr, (int)strlen(cStr), digest );      // 把str字符串转换成为32位的16进制数列，存到了result这个空间中
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", digest[i]];   // 将16字节的16进制转成32字节的16进制字符串
    }
    return [result uppercaseString];                // 大写字母字符串
}

@end

@implementation NSDictionary (GHNetworkModule)

- (NSString *)toJsonString {
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    if (error || data.length == 0) {
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSData *)toJsonData {
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    if (error || data.length == 0) {
        return nil;
    }
    return data;
}

@end
