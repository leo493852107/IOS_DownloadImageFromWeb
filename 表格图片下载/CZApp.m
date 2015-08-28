//
//  CZApp.m
//  02-表格图片xiazai
//
//  Created by leo on 15/8/27.
//  Copyright (c) 2015年 leo. All rights reserved.
//

#import "CZApp.h"

@implementation CZApp

+ (instancetype)appWithDict:(NSDictionary *)dict{
    CZApp *app = [[self alloc]init];
    
    [app setValuesForKeysWithDictionary:dict];
    
    return app;
}

@end
