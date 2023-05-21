//
//  NSURLSession+LPHttpProxy.h
//  NAU_LIPENG_FinalProject
//
//  Created by lee on 2023/5/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLSession (LPHttpProxy)
+(void)disableHttpProxy;
+(void)enableHttpProxy;
@end

NS_ASSUME_NONNULL_END
