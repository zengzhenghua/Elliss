//
//  WebHeard.h
//  EllissProject
//
//  Created by 高继鹏 on 15/5/22.
//  Copyright (c) 2015年 高继鹏. All rights reserved.
//

#import <Foundation/Foundation.h>

//@protocol cookieDelegate <NSObject>
//
//-(void)doAnythingToGetACookie;
//
//@end


@interface WebHeard : NSObject

@property (nonatomic,copy)NSString *userName;
@property (nonatomic,copy)NSString *passWord;

//该方法简化其它步骤，供使用人员快速调用
//参数一：要进入的端口
//参数二：进入端口时要附带的信息，没有的时候写nil
-(void)linkToEllissServerOnPort:(NSString*)uRL_Port withWord:(NSString*)keyWord;

@end
