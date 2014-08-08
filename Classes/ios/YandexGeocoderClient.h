#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "YandexGeocoder.h"


@interface YandexGeocoderClient : NSObject
{
    AFHTTPRequestOperationManager *_operationManager;
    NSString *_baseUrl;
}

- (id)initWithBaseURL:(NSString *)url;

- (void)getPath:(NSString *)path delegate:(id)delegate parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure;

- (void)cancelAllOperationsForDelegate:(id)delegate;

@end