//
//  CZApp.h
//  02-表格图片xiazai
//
//  Created by leo on 15/8/27.
//  Copyright (c) 2015年 leo. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <UIKit/UIKit.h>

@interface CZApp : NSObject

@property (nonatomic, copy)NSString *name;
@property (nonatomic, copy)NSString *icon;
@property (nonatomic, copy)NSString *download;

/**
 *  保存网络下载的图像
 */
//@property (nonatomic, strong)UIImage *image;

+ (instancetype)appWithDict:(NSDictionary *)dict;

@end
