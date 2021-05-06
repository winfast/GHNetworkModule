//
//  NSString+GHNetworkModule.h
//  GHNetworkModule
//
//  Created by Qincc on 2020/12/12.
//

#import <Foundation/Foundation.h>

@interface NSString (GHNetworkModule)

/**  转换为Base64编码 */
- (NSString *)base64EncodedString:(NSDataBase64EncodingOptions)options;

/** 将Base64编码还原  */
- (NSString *)base64DecodedString:(NSDataBase64DecodingOptions)options;

- (NSString *)md5To32UppercaseString;

@end

@interface NSDictionary (GHNetworkModule)

- (NSString *)toJsonString;

- (NSData *)toJsonData;

@end



