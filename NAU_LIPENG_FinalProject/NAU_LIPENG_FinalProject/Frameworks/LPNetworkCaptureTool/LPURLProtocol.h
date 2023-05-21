//
//  LPURLProtocol.h
//  NAU_LIPENG_FinalProject
//
//  Created by lee on 2023/5/22.
//
#import <Foundation/Foundation.h>
@interface LPURLProtocol : NSURLProtocol
@property (nonatomic, copy) NSURLRequest *(^requestBlock)(NSURLRequest *request);
@property (nonatomic, copy) NSData *(^responseBlock)(NSURLResponse *response, NSData *data);
@property (nonatomic, copy) NSURLSession *(^sessionBlock)(NSURLSession *session);
+(instancetype)sharedInstance;
@end
