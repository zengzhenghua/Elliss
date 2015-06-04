//
//  NSString+URL.m
//  EllissProject
//
//  Created by ABC on 15/5/29.
//  Copyright (c) 2015年 高继鹏. All rights reserved.
//

#import "NSString+URL.h"

@implementation NSString(URL)


-(NSString*)URLEncodedString:(NSString*)value
{
              NSArray *arrayKey=@[@"%",
                                  @"!", @"*", @"'",
                                  @"(", @")", @";",
                                  @":", @"@", @"&",
                                  @"=", @"+", @"$",
                                  @",", @"/", @"?",
                                  @"#", @"[",
                                  @"]"];
    
    
            NSArray *arrayValue=@[@"%25",
                                  @"%21", @"%2A", @"%27",
                                  @"%28", @"%29", @"%3B",
                                  @"%3A", @"%40", @"%26",
                                  @"%3D", @"%2B", @"%24",
                                  @"%2C", @"%2F", @"%3F",
                                  @"%23", @"%5B",
                                  @"%5D"];
    
//    NSDictionary *uRLDictionary=[[NSDictionary alloc]initWithObjects:arrayValue forKeys:arrayKey];
    //第一种设计思维：通过抽取出value每个字符的值与数组中的元素匹配，如果相等则替换
//    NSMutableString *urlAppenWord=[[NSMutableString alloc]init];
//    NSInteger urlLength=[value length];
//    NSInteger urlI;
//    
//    for (int i=0; i<urlLength+urlI; i++) {
//        char word=[value characterAtIndex:i];
//        NSLog(@"现在遍历到的字符是:%c",word);
//        NSString *cStr=[NSString stringWithFormat:@"%c",word];
//        
//        for (NSInteger j=0; j<arrayKey.count; j++) {
//            if ([cStr isEqualToString:arrayKey[j]]) {
//                NSLog(@"我要替换：%@这个字符 变成：%@字符了",cStr,arrayValue[j]);
//                [cStr stringByAppendingString:arrayValue[j]];
////                i+=1;
//                urlI+=3;
//                continue;
//            }
//        }
//        urlAppenWord=[urlAppenWord stringByAppendingString:cStr];
//    }
//    NSLog(@"appenword:%@",urlAppenWord);
    
    
    
    //第二种设计思维：遍历每个数组元素，看value字符串里是否有相同的字符串，然后替换
    /*-------------------------------------------------------------------------------------------*/
//    NSString *transformStr=[[NSString alloc]initWithString:value];//修改后的字符
//    NSString *subString=[[NSString alloc]initWithString:value];//剪刀字符
//    NSRange transformRange;
//    NSRange subRange;
//    
//    for (NSInteger i=0; i<arrayKey.count; i++) {
//        transformRange=[transformStr rangeOfString:arrayKey[i]];//确定要搜索的范围，现在两个检测头的数据保持一致
//        subRange=transformRange;
//        
//        if (transformRange.location<=[transformStr length]) {//判断是否出现了该字符，如果出现了则替换，然后再次判断有没有重复出现该字符
//            subString=[transformStr substringFromIndex:transformRange.location];//用于隔离前面与后续的字符串，判断后面出现相同的字符串源数据
//            transformStr=[transformStr stringByReplacingOccurrencesOfString:arrayKey[i] withString:arrayValue[i]];//经过转换后的字符串，在非“%”的情况下
//            
//            subRange=[subString rangeOfString:arrayKey[i]];//用于判断是否还存在相同的字符串
//            if ([arrayKey[i] isEqual:@"%"] && subRange.location<=[subString length]) {//"%"字符的特殊处理
//                NSLog(@"!!!!");
//            }else if(subRange.location<=[subString length]){
//                while (subRange.location<=[subString length])                                                                                                                                                                                                                       {
//                    transformStr=[transformStr stringByReplacingOccurrencesOfString:arrayKey[i] withString:arrayValue[i]];//直到修改完全
//                    subString=[subString substringFromIndex:subRange.location+subRange.length];
//                    subRange=[subString rangeOfString:arrayKey[i]];
//                    NSLog(@"subRange.location:%ld \tsubSTR:%@ \ttransfoem:%@",subRange.location,subString,transformStr);
//                }
//                
//            }
//            
//        }
//    }
    //    NSLog(@"trans:%@",transformStr);
    //    return transformStr;

    //第三种设计思维：遍历每个数组元素，看value字符串里是否有相同的字符串，然后替换
    /*-------------------------------------------------------------------------------------------*/
    
    for (NSInteger i=0; i<arrayKey.count; i++) {
        NSRange range=[value rangeOfString:arrayKey[i]];
        if (range.location<=[value length]) {
            value=[value stringByReplacingOccurrencesOfString:arrayKey[i] withString:arrayValue[i]];
        }
    }
    
//    NSLog(@"NSString+URL修改过后\tvalue:%@",value);
    return value;
}
@end
