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
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        [_sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
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
- (void)getPath:(NSString *)path
       delegate:(id)delegate
     parameters:(NSDictionary *)parameters
        success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
        failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    
    NSURLSessionDataTask *dataTask = [_sessionManager GET:[_baseUrl stringByAppendingString:path]
                                               parameters:parameters
                                                 progress:nil
                                                  success:success
                                                  failure:failure];
 
    objc_setAssociatedObject(dataTask, &kGeocodingOperationDelegateObjectKey, delegate, OBJC_ASSOCIATION_ASSIGN);
}

/** Cancels all operations associated with delegate
*
* @param delegate Delegate
*/
- (void)cancelAllOperationsForDelegate:(id)delegate
{
    for (NSURLSessionDataTask *task in _sessionManager.dataTasks) {
        BOOL match = (id)objc_getAssociatedObject(task, &kGeocodingOperationDelegateObjectKey) == delegate;
        
        if (match) {
            [task cancel];
        }
    }
}

@end
