//
//  WebHeard.m
//  EllissProject
//
//  Created by 高继鹏 on 15/5/22.
//  Copyright (c) 2015年 高继鹏. All rights reserved.
//

#import "WebHeard.h"
#import "CommonCrypto/CommonDigest.h"
#import <CommonCrypto/CommonHMAC.h>
#import "AFHTTPRequestOperationManager.h"
#import "MD5/NSString+Hashing.h"
#import "NSString+URL.h"

#define ELLISS_HOST @"http://www.elliss.cn/"
#define HttpMethod @"POST"
@implementation WebHeard
{
    NSString *_nowDateStr;
    NSString *_authorization;
    NSString *_content_Type;
    NSString *_content_Length;
    NSString *_content_MD5;
    NSString *_cookie;
    NSString *_connection;
    NSString *_userAgent;
    
    NSString *_content;
    NSString *_secretKey;//密钥得要给出来
    NSString *_ciphertextPassword;//变成密文的密码
    NSDictionary *_postDict;//post出去的表单
    
    NSString *_url_port;//这是个选择要进入端口的量，从对外的方法中获得
    AFHTTPRequestOperationManager *manager;
    
}

//要设计成单例模式
-(id)init
{
    self=[super init];
    if (self) {
        [self initHttpManager];//初始化网络申请请求manager
        //获取cookie

    }
    return self;
}

//初始化网络申请请求manager
-(void)initHttpManager
{
    manager=[AFHTTPRequestOperationManager manager];
}
//请求post封装成某种类型的
-(void)postDataWith:(NSDictionary*)postDict andAcceptableContentTypes:(NSString*)contentTypes andPort:(NSString*)uRL_Port
{
    [manager.requestSerializer setValue:_nowDateStr forHTTPHeaderField:@"DATE"];
    [manager.requestSerializer setValue:_authorization forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:_content_Length forHTTPHeaderField:@"Content-Length"];
    [manager.requestSerializer setValue:_content_Type forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:_content_MD5 forHTTPHeaderField:@"Content-MD5"];
    [manager.requestSerializer setValue:_connection forHTTPHeaderField:@"Connection"];
    [manager.requestSerializer setValue:_userAgent forHTTPHeaderField:@"User-Agent"];
    
    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObject:contentTypes];
    NSLog(@"content:%@",_content);
    [manager POST:uRL_Port parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR:%@",error.description);
    }];
}

//2.0使用相关请求方式,根据port的关键字不同，调用不同的方法得到返回的数据
-(void)linkToEllissServerOnPort:(NSString*)uRL_Port withWord:(NSString*)keyWord
{
    _url_port=uRL_Port;
    
    if ([uRL_Port isEqualToString:@"au/r/"]) {//注册时发送验证码
        
        //张晓军写
        [self getFindBackMessageOrEmail:self.userName];

    }else if ([uRL_Port isEqualToString:@"au/f/"]){//找回密码时发送验证码
        
    }else if ([uRL_Port isEqualToString:@"au/a/"]){//邮箱激活（无需APP主动调用）？
        
    }else if ([uRL_Port isEqualToString:@"r"]){//用户注册
        
    }else if ([uRL_Port isEqualToString:@"l"]){//用户登录
        
        [self getCookies];
       
    }else if ([uRL_Port isEqualToString:@"f"]){//找回密码
        
    }else if ([uRL_Port isEqualToString:@"upi"]){//更新个人信息
        
    }else if ([uRL_Port isEqualToString:@"mp"]){//下载模式
        
    }else if ([uRL_Port isEqualToString:@"w"]){//发送模式
        
    }else{
        return NSLog(@"Error:非法关键字");
    }
}
/**
 *  用于翻译content的键值内容
 *
 *  @param  这个可以变成return过去的类型
 *
 *  @return 返回所需要的格式
 */
-(NSString*)transformContent
{
    NSString *name=_postDict[@"LoginForm"][@"username"];
    NSString *password=_postDict[@"LoginForm"][@"password"];
    NSString *cookie=_postDict[@"_csrf"];
    
    name=[name URLEncodedString:name];
    password=[password URLEncodedString:password];
    cookie=[cookie URLEncodedString:cookie];
    
    NSString *strName=@"[username]";
    NSString *strPassword=@"[password]";
    NSString *strRemember=@"[rememberMe]";
    
    strName=[strName URLEncodedString:strName];
    strPassword=[strPassword URLEncodedString:strPassword];
    strRemember=[strRemember URLEncodedString:strRemember];
    
//    NSString *string=[NSString stringWithFormat:@"_csrf=%@&LoginForm%%5Busername%%5D=%@&LoginForm%%5Bpassword%%5D=%@&LoginForm%%5BrememberMe%%5D=%@",cookie,name,password,@"0"];
    NSString *string=[NSString stringWithFormat:@"_csrf=%@&LoginForm%@=%@&LoginForm%@=%@&LoginForm%@=%@",cookie,strName,name,strPassword,password,strRemember,@"0"];
    NSLog(@"length:%ld",[string length]);
    
    return string;
}

//2.1有关请求头的描述
-(void)initHttpHeaderDescrition
{
    //设置时间
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"EEE,d MMM yy hh:mm:ss Z"];
    _nowDateStr=[dateFormatter stringFromDate:[NSDate date]];
//    _nowDateStr=@"Thu,28 May 15 04:01:51 +0800";
    
    //content的内容为post上来的表单
    NSData *contentData=[NSJSONSerialization dataWithJSONObject:_postDict options:NSJSONWritingPrettyPrinted error:nil];
    _content=[[NSString alloc]initWithData:contentData encoding:NSUTF8StringEncoding];
    _content=[self transformContent];
//    _content=@"_csrf=YXl1X3lGQVE3HQ8vGxkIHSZILxs4MTRnL0kHcjAOAmZXDDE.AyszMA%3D%3D&LoginForm%5Busername%5D=1789%40126.com&LoginForm%5Bpassword%5D=0F3012EF6FA0D083669FC28C86BE4AEE&LoginForm%5BrememberMe%5D=0";

    //post上来的经过序列化之后的数据长度
    _content_Length=[NSString stringWithFormat:@"%ld",_content.length];
    
    //Content-Type固定值
    _content_Type=@"application/x-www-form-urlencoded";
    
    //Content-MD5 post上来的经过序列化之后的数据MD5,并转换成小写
    _content_MD5=[[_content MD5Hash] lowercaseString];
    
    //Connection
    _connection=@"close";
    
    //UserAgent的固定值
    _userAgent=@"NoBody/1.0 (LeBerry; U; CPU iPhone OS or Android; zh-CN) I_Know_Nothing";
    
    //Authorization验证签名字符串，密钥得要补充
    _authorization=[self prepareAuthorizationSign];
}

//2.2签名算法   secretKey为密钥
-(NSString*)prepareAuthorizationSign
{
    _secretKey=@"22222222";
    NSString *httpMethod=@"POST";
    NSString *canonicalizedHeaders=[NSString stringWithFormat:@"%@\n%@\n%@\n",_content_MD5,_content_Type,_nowDateStr];
//    NSLog(@"header:%@",canonicalizedHeaders);
    NSString *canonicalizedResource=_url_port;
//    NSLog(@"Resource:%@",canonicalizedResource);
    NSString *strSignData=[NSString stringWithFormat:@"%@\n%@\\%@",httpMethod,canonicalizedHeaders,canonicalizedResource];
//    NSLog(@"strSignData:%@",strSignData);
    strSignData=[WebHeard hmacsha1:strSignData key:_secretKey];//这里不需要再对它做base64的转换，貌似后台会处理
    //strSignData = @"_csrf=YXl1X3lGQVE3HQ8vGxkIHSZILxs4MTRnL0kHcjAOAmZXDDE.AyszMA%3D%3D&LoginForm%5Busername%5D=1789%40126.com&LoginForm%5Bpassword%5D=0F3012EF6FA0D083669FC28C86BE4AEE&LoginForm%5BrememberMe%5D=0";
    NSString *strSign=[NSString stringWithFormat:@"ILBv1.0:%@",strSignData];
//    NSLog(@"strSign:%@",strSign);
    return strSign;
}

//2.3注册时获取短信验证码或邮箱333
-(void)getRegistMessageOrEmail:(NSString*)phoneOrEmail
{
    NSData *userNameData=[phoneOrEmail dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *userNameBase64=[userNameData base64EncodedStringWithOptions:0];
    NSString *strA=[@"http://www.elliss.cn/au/r/" stringByAppendingString:userNameBase64];
    _url_port = strA;
    
    
}

//2.4找回密码时获取短信验证码或邮箱接收验证码
-(void)getFindBackMessageOrEmail:(NSString*)phoneOrEmail
{
    
}

//2.5用户注册方法
-(void)rigistFormWithName:(NSString*)userName andPassWord:(NSString*)passWord
{
    
}

//2.6用户登录方法
-(NSDictionary*)loginServerWithName:(NSString*)userName andPassWord:(NSString*)passWord
{
    //对密码进行密文转换
    _ciphertextPassword=[self createCiphertextPassword];
    
    Boolean rememberMe=false;
    NSNumber *remeberMeNum=[NSNumber numberWithBool:rememberMe];
    
    NSDictionary *loginForm=@{@"username":userName,@"password":_ciphertextPassword,@"rememberMe":remeberMeNum};
    NSDictionary *postDirt=@{@"_csrf":_cookie,@"LoginForm":loginForm};
    _postDict=postDirt;
    return postDirt;
}

//2.7该接口用于用户找回密码(个人觉得还有重置密码的意思)。
-(void)findUserPassWord
{
    
}

//2.8下载模式
-(void)downLoadLoveStyle
{
    
}

//2.9更新个人信息
-(void)updataUserInformation
{
    
}

//2.10发送信息
-(void)sendAppdataToServer
{
    
}

-(void)getCookies
{
    
    NSURL *url =[[NSURL alloc]initWithString:@"http://www.elliss.cn/l"];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];
    AFHTTPRequestOperation *operation =[[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                if ([operation.response respondsToSelector:@selector(allHeaderFields)]) {
            // 取得所有请求的头
//            NSDictionary *dictionary = [operation.response allHeaderFields];
//            NSLog(@"%@",dictionary);
            // 处理字符串，取得所需ST值
//            NSString *set_Cookie_String = [dictionary objectForKey:@"Set-Cookie"];

                    NSString *str=[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
//                    NSLog(@"=====================%@",str);
                    NSRange range=[str rangeOfString:@" <title>Login</title>"];
                    str=[str substringToIndex:range.location];
                    range=[str rangeOfString:@"csrf-token\" content=\""];
                    str=[str substringFromIndex:range.location];
                    range=[str rangeOfString:@"=\""];
                    str=[str substringFromIndex:range.location];
                    range=[str rangeOfString:@"\""];
                    str=[str substringFromIndex:range.location+1];
                    range=[str rangeOfString:@"\""];
                    str=[str substringToIndex:range.location];
                    
                    _cookie=str;
//                    _cookie=@"YXl1X3lGQVE3HQ8vGxkIHSZILxs4MTRnL0kHcjAOAmZXDDE.AyszMA==";
//                    _cookie=set_Cookie_String;
//                    NSRange range1=[set_Cookie_String rangeOfString:@";"];
//                    _cookie=[set_Cookie_String substringWithRange:NSMakeRange(0, range1.location)];
                    //                    NSLog(@"_cookie:%@",_cookie);

                    
                    NSDictionary *postDict=[self loginServerWithName:self.userName andPassWord:self.passWord];//设置请求体
                    [self initHttpHeaderDescrition];//初始化所需要的字段(私有的字段)
                    [self postDataWith:postDict andAcceptableContentTypes:@"text/html" andPort:[ELLISS_HOST stringByAppendingString:@"l"]];//请求数据
                    
                    
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
    }];
    [operation start];
}

//密码密文加密算法综合
-(NSString*)createCiphertextPassword
{
    NSString *userNameMD5=[self.userName MD5Hash];
    NSData *passwordData=[self.passWord dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *passwordBase64=[passwordData base64EncodedStringWithOptions:0];
    NSString *strA=[passwordBase64 stringByAppendingString:userNameMD5];
    strA=[strA MD5Hash];
    NSString *strB=[[userNameMD5 substringToIndex:8] stringByAppendingString:strA];
    strB=[strB stringByAppendingString:[userNameMD5 substringWithRange:NSMakeRange(8, 8)]];
    strB=[strB MD5Hash];
    return strB;
}

//HmacSHA1算法
+(NSString*)hmacsha1:(NSString*)text key:(NSString*)secret
{
    NSData *secretData=[secret dataUsingEncoding:NSUTF8StringEncoding];
    NSData *clearTextData=[text dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[20];
    CCHmac(kCCHmacAlgSHA1, [secretData bytes], [secretData length], [clearTextData bytes], [clearTextData length], result);
    NSData *data1=[NSData dataWithBytes:result length:sizeof(result)];
    NSString *hash=[data1 base64EncodedStringWithOptions:0];//这边的第二个参数是填写什么合适
    return hash;
    
}
/******************************** 获得短信验证的get请求  *****************************/
-(NSString*)getnformation
{

    NSURL *url                        = [NSURL URLWithString:_url_port];
    NSURLRequest *request             = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation =[[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"获得短信验证的get请求:%@",responseObject);
    
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"失败");
    }];
    [operation start];
    return nil;
}

@end
