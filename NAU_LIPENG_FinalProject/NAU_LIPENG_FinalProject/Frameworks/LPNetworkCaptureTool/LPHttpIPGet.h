//
//  LPHttpIPGet.h
//  NAU_LIPENG_FinalProject
//
//  Created by lee on 2023/5/22.
//

#import <Foundation/Foundation.h>

@interface LPHttpIPGet : NSObject
+(NSString *)getIPArrFromLocalDnsWithUrlStr:(NSString *)urlStr;
@end
