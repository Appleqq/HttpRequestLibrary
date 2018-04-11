//
//  DSDataTransformerTool.m
//  SPRequestLibrary
//
//  Created by ppan on 2018/4/11.
//  Copyright © 2018年 ppan. All rights reserved.
//

#import "DSDataTransformerTool.h"
#import "YYModel.h"
@implementation DSDataTransformerTool

+ (id)getJsonWithModel:(id)model {
    
    return [model yy_modelToJSONObject];
}

+ (instancetype)getModel:(Class)modelClass json:(id)json {
    
    return [modelClass yy_modelWithJSON:json];
}

+(NSArray *)getModelArr:(Class)modelClass json:(id)json {
    
    return [NSArray yy_modelArrayWithClass:modelClass json:json];
}

+ (NSString *)jsonStringWithJsonObj:(id)json {
    if ([NSJSONSerialization isValidJSONObject:json])
    {
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
        NSString * jsonStr = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        return jsonStr;
    }
    return nil;
}
@end
