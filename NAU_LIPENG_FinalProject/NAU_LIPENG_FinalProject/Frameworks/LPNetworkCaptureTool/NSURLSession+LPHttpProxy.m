//
//  NSURLSession+LPHttpProxy.m
//  NAU_LIPENG_FinalProject
//
//  Created by lee on 2023/5/22.
//

#import "NSURLSession+LPHttpProxy.h"
#import "LPURLProtocol.h"
#import <objc/runtime.h>
static BOOL isDisableHttpProxy = NO;
@implementation NSURLSession (LPHttpProxy)
+(void)load{
    [super load];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSURLProtocol registerClass:[LPURLProtocol class]];
        Class class = [NSURLSession class];
        [self swizzingMethodWithClass:class orgSel:NSSelectorFromString(@"sessionWithConfiguration:") swiSel:NSSelectorFromString(@"zx_sessionWithConfiguration:")];
        [self swizzingMethodWithClass:class orgSel:NSSelectorFromString(@"sessionWithConfiguration:delegate:delegateQueue:") swiSel:NSSelectorFromString(@"zx_sessionWithConfiguration:delegate:delegateQueue:")];
    });
}
+(void)disableHttpProxy{
    isDisableHttpProxy = YES;
}
+(void)enableHttpProxy{
    isDisableHttpProxy = NO;
}
+(NSURLSession *)zx_sessionWithConfiguration:(NSURLSessionConfiguration *)configuration
                                    delegate:(nullable id<NSURLSessionDelegate>)delegate
                               delegateQueue:(nullable NSOperationQueue *)queue{
    if (!configuration){
        configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    }
    if(isDisableHttpProxy){
        configuration.connectionProxyDictionary = @{};
    }
    return [self zx_sessionWithConfiguration:configuration delegate:delegate delegateQueue:queue];
}

+(NSURLSession *)zx_sessionWithConfiguration:(NSURLSessionConfiguration *)configuration{
    if (configuration && isDisableHttpProxy){
        configuration.connectionProxyDictionary = @{};
    }
    return [self zx_sessionWithConfiguration:configuration];
}

+(void)swizzingMethodWithClass:(Class)cls orgSel:(SEL) orgSel swiSel:(SEL) swiSel{
    Method orgMethod = class_getClassMethod(cls, orgSel);
    Method swiMethod = class_getClassMethod(cls, swiSel);
    method_exchangeImplementations(orgMethod, swiMethod);
}

@end
