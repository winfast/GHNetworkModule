//
//  GHViewController.h
//  GHNetworkModule
//
//  Created by Qincc on 12/12/2020.
//  Copyright (c) 2020 Qincc. All rights reserved.
//

@import UIKit;
#import "GHNetworkBaseRequest.h"

@interface GHViewController : UIViewController

@end


@interface GHLoginRequest : GHNetworkBaseRequest

/// 手机号\邮箱
@property (nonatomic, copy) NSString *username;

/// 密码（密码由 8 - 128 字符组成，不能为纯数字或字母）
@property (nonatomic, copy) NSString *password;

/// 国家码简称
@property (nonatomic, copy) NSString *region_code;

/// 手机号国家码
@property (nonatomic, copy) NSNumber *phone_code;

@end
