/** Yandex Geocoder Client
*
* Maintains list of delegates, so each of them could cancel all requests associated with it.
*/

#import <objc/runtime.h>
#import "YandexGeocoderClient.h"
#import "AFNetworking.h"

static char kGeocodingOperationDelegateObjectKey;

@interface YandexGeocoderClient ()

@end

@implementation YandexGeocoderClient
{

}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self) {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
    }

    return self;
}

/** Makes request, maps list of operations to given delegate;
*
* @param path Relative url
* @param delegate Delegate
* @param parameters GET-params
* @param success Completion block
* @param failure Failure block
*/
- (void)getPath:(NSString *)path delegate:(id<YandexGeocoderDelegate>)delegate parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];

    objc_setAssociatedObject(operation, &kGeocodingOperationDelegateObjectKey, delegate, OBJC_ASSOCIATION_ASSIGN);

    [self enqueueHTTPRequestOperation:operation];
}

/** Cancels all operations associated with delegate
*
* @param delegate Delegate
*/
- (void)cancelAllOperationsForDelegate:(id<YandexGeocoderDelegate>)delegate
{
    for (NSOperation *operation in [self.operationQueue operations]) {
        if (![operation isKindOfClass:[AFHTTPRequestOperation class]]) {
            continue;
        }

        BOOL match = (id<YandexGeocoderDelegate>)objc_getAssociatedObject(operation, &kGeocodingOperationDelegateObjectKey) == delegate;

        if (match) {
            [operation cancel];
        }
    }
}

@end