#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "YandexGeocoder.h"


NS_ASSUME_NONNULL_BEGIN

@interface YandexGeocoderClient : NSObject
{
    AFHTTPSessionManager *_sessionManager;
    NSString *_baseUrl;
}

- (id)initWithBaseURL:(NSString *)url;

- (void)getPath:(NSString *)path
       delegate:(id)delegate
     parameters:(NSDictionary *)parameters
        success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
        failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (void)cancelAllOperationsForDelegate:(id)delegate;

@end

NS_ASSUME_NONNULL_END
