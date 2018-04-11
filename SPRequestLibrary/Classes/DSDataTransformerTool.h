//
//  DSDataTransformerTool.h
//  SPRequestLibrary
//
//  Created by ppan on 2018/4/11.
//  Copyright © 2018年 ppan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DSDataTransformerTool : NSObject

/**
 model 转json

 @param model 对象
 @return json 数据
 */
+ (id)getJsonWithModel:(id)model;


/**
 json转model

 @param modelClass 模型类型
 @param json json数据
 @return model 对象
 */
+ (instancetype)getModel:(Class)modelClass json:(id)json;


/**
 json 转 数组模型

 @param modelClass 模型类型
 @param json json数据
 @return model对象数组
 */
+ (NSArray*)getModelArr:(Class)modelClass json:(id)json;


/**
 json 转 字符串

 @param json json 数据
 @return json 字符串
 */
+ (NSString *)jsonStringWithJsonObj:(id)json;
@end
