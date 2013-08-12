#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "AFNetworking.h"

#define kYandexGeocoderBaseUrl @"http://geocode-maps.yandex.ru"
#define kYandexGeocoderEarthRadius 6371000.01

@class YandexGeocoderClient;


@interface YandexGeocoder : NSObject

+ (id)sharedInstance;

- (void)cancelAllRequestsForDelegate:(id)delegate;

- (void)reversedGeocodingForLatitude:(double)latitude longitude:(double)longitude success:(void (^)(AFHTTPRequestOperation *operation, id responseObject, NSDictionary *places))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure owner:(id)owner;

- (void)reversedGeocodingForLatitude:(double)latitude longitude:(double)longitude language:(NSString *)language success:(void (^)(AFHTTPRequestOperation *operation, id responseObject, NSDictionary *places))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure owner:(id)owner;

- (void)reversedGeocodingForLatitude:(double)latitude longitude:(double)longitude language:(NSString *)language kind:(NSString *)kind success:(void (^)(AFHTTPRequestOperation *operation, id responseObject, NSDictionary *places))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure owner:(id)owner;

- (void)forwardGeocoding:(NSString *)address success:(void (^)(AFHTTPRequestOperation *operation, id responseObject, NSDictionary *places))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure owner:(id)owner;

- (void)forwardGeocoding:(NSString *)address limitCenterLat:(double)limitCenterLat limitCenterLng:(double)limitCenterLng radius:(double)radius limitToBounds:(BOOL)limitToBounds language:(NSString *)language success:(void (^)(AFHTTPRequestOperation *operation, id responseObject, NSDictionary *places))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure owner:(id)owner;

+ (CLLocation *)locationFromObject:(NSDictionary *)object;

+ (NSString *)titleFromObject:(NSDictionary *)object;

+ (NSString *)cityFromObject:(NSDictionary *)object;

+ (NSString *)placeTypeFromObject:(NSDictionary *)object;

@end