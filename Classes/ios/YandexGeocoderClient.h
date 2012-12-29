#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"
#import "YandexGeocoder.h"

@class AFHTTPRequestOperation;


@interface YandexGeocoderClient : AFHTTPClient
- (void)getPath:(NSString *)path delegate:(id <YandexGeocoderDelegate>)delegate parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure;

- (void)cancelAllOperationsForDelegate:(id <YandexGeocoderDelegate>)delegate;

@end