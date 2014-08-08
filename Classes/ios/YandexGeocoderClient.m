/** Yandex Geocoder Client
*
* Maintains list of delegates, so each of them could cancel all requests associated with it.
*/

#import <objc/runtime.h>
#import "YandexGeocoderClient.h"

static char kGeocodingOperationDelegateObjectKey;

@interface YandexGeocoderClient ()

@end

@implementation YandexGeocoderClient

- (id)initWithBaseURL:(NSString *)url
{
    self = [super init];
    if (self) {
        _operationManager = [AFHTTPRequestOperationManager manager];
        _operationManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        [_operationManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        _baseUrl = url;
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
- (void)getPath:(NSString *)path delegate:(id)delegate parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    
    AFHTTPRequestOperation *operation = [_operationManager GET:[_baseUrl stringByAppendingString:path]
                                                    parameters:parameters
                                                       success:success
                                                       failure:failure];
 
    objc_setAssociatedObject(operation, &kGeocodingOperationDelegateObjectKey, delegate, OBJC_ASSOCIATION_ASSIGN);
}

/** Cancels all operations associated with delegate
*
* @param delegate Delegate
*/
- (void)cancelAllOperationsForDelegate:(id)delegate
{
    for (NSOperation *operation in [_operationManager.operationQueue operations]) {
        if (![operation isKindOfClass:[AFHTTPRequestOperation class]]) {
            continue;
        }

        BOOL match = (id)objc_getAssociatedObject(operation, &kGeocodingOperationDelegateObjectKey) == delegate;

        if (match) {
            [operation cancel];
        }
    }
}

@end