/**
* Use Yandex Geocoding API for forward and reversed geocoding.
*/

#import "YandexGeocoder.h"
#import "YandexGeocoderClient.h"

@interface YandexGeocoder ()

- (void) makeRequestWithParams: (NSMutableDictionary*) params
                       success: (void (^)(NSURLSessionDataTask *task, id responseObject, NSDictionary* places)) success
                       failure: (void (^)(NSURLSessionDataTask *task, NSError* error)) failure
                         owner: (id) owner;

- (NSMutableDictionary*) convertResponse: (id) responseObject;

- (double) radiansWithDistance: (double) meters;

@property(readonly, strong) YandexGeocoderClient* client;

@end

@implementation YandexGeocoder
{

}

@synthesize client = _client;

/** Singleton
*
* @return id
*/
+ (id) sharedInstance
{
    static YandexGeocoder* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(
        &onceToken, ^
        {
            sharedInstance = [[self alloc] init];
        });
    return sharedInstance;
}

- (id) init
{
    if (self = [super init])
    {
        _client = [[YandexGeocoderClient alloc] initWithBaseURL: kYandexGeocoderBaseUrl];
    }
    return self;
}

#pragma mark - Helpers
/**@name Helpers */

/** Makes actual request
*
* Adds required parameters to each request.
*
* @param params GET-parameters
* @param owner Delegate than will be notified upon request completion
*/
- (void) makeRequestWithParams: (NSMutableDictionary*) params
                       success: (void (^)(NSURLSessionDataTask *task, id responseObject, NSDictionary* places)) success
                       failure: (void (^)(NSURLSessionDataTask *task, NSError* error)) failure
                         owner: (id) owner
{
    params[@"sco"] = @"longlat"; //coordinates order
    params[@"format"] = @"json";

    if (params[@"lang"] == nil)
    {
        params[@"lang"] = [[NSLocale currentLocale] localeIdentifier];
    }

    [self.client getPath: @"1.x/" delegate: owner parameters: params
                 success: ^(NSURLSessionDataTask *task, id responseObject)
                 {
#ifdef DDLogInfo
        DDLogInfo(@"Yandex Geocoder finished");
#else
                     NSLog(@"Yandex Geocoder finished");
#endif
                     NSMutableDictionary* places = [self convertResponse: responseObject];
                     if (places.count > 0)
                     {
                         success(task, responseObject, places);
                     }
                     else
                     {
                         failure(task, [NSError errorWithDomain: @"com.yandex.geocode" code: 404
                                                        userInfo: @{@"error" : @"Can't find places"}]);
                     }
                 } failure: ^(NSURLSessionDataTask *task, NSError* error)
    {
#ifdef DDLogError
        DDLogError(@"Yandex Geocoder failed");
#else
        NSLog(@"Yandex Geocoder failed");
#endif
        failure(task, error);
    }];
}

/** Cancels all requests associated with given delegate
*
*/
- (void) cancelAllRequestsForDelegate: (id) delegate
{
    [self.client cancelAllOperationsForDelegate: delegate];
}

/** Converts response to more simple structure
*
* @param responseObject JSON response
* @return Simplified response
*/
- (NSMutableDictionary*) convertResponse: (id) responseObject
{
    NSMutableDictionary* result = [NSMutableDictionary dictionary];

    result[@"total"] = responseObject[@"response"][@"GeoObjectCollection"][@"metaDataProperty"][@"GeocoderResponseMetaData"][@"found"] ?: @"";

    NSMutableArray* places = [NSMutableArray array];

    if (responseObject[@"response"][@"GeoObjectCollection"][@"featureMember"])
    {
        [(NSArray*) responseObject[@"response"][@"GeoObjectCollection"][@"featureMember"] enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL* stop)
        {
            [places addObject: obj[@"GeoObject"]];
        }];
    }

    result[@"places"] = places;

    return result;
}

/**
*   s = r * θ;
*   s = arc length covered;
*   r = radius of the circle;
*   θ = angle in radians;
*
* Earth radius ~ 6371000.01
*
* @param meters Distance in meters
* @return radians
*/
- (double) radiansWithDistance: (double) meters
{
    return meters / kYandexGeocoderEarthRadius;
}

/** Extracts coordinates from place
*
* @param object Place item returned by convertResponse:
* @return CLLocation
*/
+ (CLLocation*) locationFromObject: (NSDictionary*) object
{
    NSArray* coords = [(NSString*) object[@"Point"][@"pos"] componentsSeparatedByString: @" "];
    CLLocation* location = [[CLLocation alloc] initWithLatitude: [(NSString*) coords[1] doubleValue]
                                                      longitude: [(NSString*) coords[0] doubleValue]];
    return location;
}

/** Extracts title from place
*
* @param object Place item returned by convertResponse:
* @return Place title
*/
+ (NSString*) titleFromObject: (NSDictionary*) object
{
    return object[@"metaDataProperty"][@"GeocoderMetaData"][@"text"];
}

/** Extracts city from place
*
* @param object Place item returned by convertResponse:
* @return Place city
*/
+ (NSString*) cityFromObject: (NSDictionary*) object
{
    NSArray* paths = @[
        @"metaDataProperty.GeocoderMetaData.AddressDetails.Country.AdministrativeArea.Locality.LocalityName",
        @"metaDataProperty.GeocoderMetaData.AddressDetails.Country.Locality.LocalityName",
        @"metaDataProperty.GeocoderMetaData.AddressDetails.Country.AdministrativeArea.SubAdministrativeArea.Locality.LocalityName"
    ];

    NSString* city;
    for (int i = 0; i < paths.count; i++)
    {
        city = [object valueForKeyPath: paths[i]];
        if (city)
        {
            break;
        }
    }

    return city;
}

/** Extracts place type from place
*
* @param object Place item returned by convertResponse:
* @return Place type
*/
+ (NSString*) placeTypeFromObject: (NSDictionary*) object
{
    return object[@"metaDataProperty"][@"GeocoderMetaData"][@"kind"];
}

#pragma mark - Geocoding
/**@name Geocoding */

/** Get list of places at point
*
* @param latitude Latitude
* @param longitude Longitude
* @param owner Delegate
*/
- (void) reversedGeocodingForLatitude: (double) latitude
                            longitude: (double) longitude
                              success: (void (^)(NSURLSessionDataTask *task, id responseObject, NSDictionary* places)) success
                              failure: (void (^)(NSURLSessionDataTask *task, NSError* error)) failure
                                owner: (id) owner
{
    [self reversedGeocodingForLatitude: latitude longitude: longitude language: nil kind: nil success: success
                               failure: failure owner: owner];
}

/** Get list of places at point
*
* @param latitude Latitude
* @param longitude Longitude
* @param language Language Code
* @param owner Delegate
*/
- (void) reversedGeocodingForLatitude: (double) latitude
                            longitude: (double) longitude
                             language: (NSString*) language
                              success: (void (^)(NSURLSessionDataTask *task, id responseObject, NSDictionary* places)) success
                              failure: (void (^)(NSURLSessionDataTask *task, NSError* error)) failure
                                owner: (id) owner
{
    [self reversedGeocodingForLatitude: latitude longitude: longitude language: language kind: nil success: success
                               failure: failure owner: owner];
}

/** Get list of places at point
*
* @param latitude Latitude
* @param longitude Longitude
* @param language Language Code
* @param kind (house, street, metro, district, locality)
* @param owner Delegate
*/
- (void) reversedGeocodingForLatitude: (double) latitude
                            longitude: (double) longitude
                             language: (NSString*) language
                                 kind: (NSString*) kind
                              success: (void (^)(NSURLSessionDataTask *task, id responseObject, NSDictionary* places)) success
                              failure: (void (^)(NSURLSessionDataTask *task, NSError* error)) failure
                                owner: (id) owner
{
#ifdef DDLogInfo
    DDLogInfo(@"Reverse geocoding: lat %f, lng %f", latitude, longitude);
#else
    NSLog(@"Reverse geocoding: lat %f, lng %f", latitude, longitude);
#endif
    NSMutableDictionary* params = [@{
        @"geocode" : [NSString stringWithFormat: @"%.07f,%.07f", longitude, latitude],
    } mutableCopy];

    if (language != nil)
    {
        params[@"lang"] = language;
    }
    if (kind != nil)
    {
        params[@"kind"] = kind;
    }
    [self makeRequestWithParams: params success: success failure: failure owner: owner];
}

/** Get list of places for address
*
* @param address Query string
* @param owner Delegate
*/
- (void) forwardGeocoding: (NSString*) address
                  success: (void (^)(NSURLSessionDataTask *task, id responseObject, NSDictionary* places)) success
                  failure: (void (^)(NSURLSessionDataTask *task, NSError* error)) failure
                    owner: (id) owner
{
#ifdef DDLogInfo
    DDLogInfo(@"Forward geocoding: %@", address);
#else
    NSLog(@"Forward geocoding: %@", address);
#endif
    NSMutableDictionary* params = [@{@"geocode" : address} mutableCopy];
    [self makeRequestWithParams: params success: success failure: failure owner: owner];
}

/** Get list of places for address
 *
 * @param address Query string
 * @param language Language Code
 * @param owner Delegate
 */
- (void) forwardGeocoding: (NSString*) address
                 language: (NSString*) language
                  success: (void (^)(NSURLSessionDataTask *task, id responseObject, NSDictionary* places)) success
                  failure: (void (^)(NSURLSessionDataTask *task, NSError* error)) failure
                    owner: (id) owner
{
#ifdef DDLogInfo
    DDLogInfo(@"Forward geocoding: %@", address);
#else
    NSLog(@"Forward geocoding: %@", address);
#endif
    NSMutableDictionary* params = [@{@"geocode" : address} mutableCopy];
    if (language != nil)
    {
        params[@"lang"] = language;
    }
    [self makeRequestWithParams: params success: success failure: failure owner: owner];
}

/** Get list of places for address
*
* @param address Query string
* @param limitCenterLat Latitude of the center of the bounding area
* @param limitCenterLng Longitude of the center of the bounding area
* @param radius Radius of the bounding area
* @param limitToBounds YES - limit search to bounding area, NO - don't limit, but return results within the bounding area first
*/
- (void) forwardGeocoding: (NSString*) address
           limitCenterLat: (double) limitCenterLat
           limitCenterLng: (double) limitCenterLng
                   radius: (double) radius
            limitToBounds: (BOOL) limitToBounds
                 language: (NSString*) language
                  success: (void (^)(NSURLSessionDataTask *task, id responseObject, NSDictionary* places)) success
                  failure: (void (^)(NSURLSessionDataTask *task, NSError* error)) failure
                    owner: (id) owner
{
#ifdef DDLogInfo
    DDLogInfo(@"Forward geocoding: %@, lat %f, lng %f, rad %f, limit %d", address, limitCenterLat, limitCenterLng, radius, limitToBounds);
#else
    NSLog(@"Forward geocoding: %@, lat %f, lng %f, rad %f, limit %d", address, limitCenterLat, limitCenterLng, radius, limitToBounds);
#endif
    NSMutableDictionary* params = [@{
        @"geocode" : address,
        @"rspn" : limitToBounds ? @"1" : @"0",
        @"ll" : [NSString stringWithFormat: @"%.07f,%.07f", limitCenterLng, limitCenterLat],
        @"spn" : [NSString stringWithFormat: @"%.07f", [self radiansWithDistance: radius]]
    } mutableCopy];

    if (language != nil)
    {
        params[@"lang"] = language;
    }

    [self makeRequestWithParams: params success: success failure: failure owner: owner];
}


/** Get list of places for address
 *
 * @param address Query string
 * @param limitCenterLat Latitude of the center of the bounding area
 * @param limitCenterLng Longitude of the center of the bounding area
 * @param spanLat span in degrees for latitude
 * @param spanLng span in degrees for longitude
 * @param limitToBounds YES - limit search to bounding area, NO - don't limit, but return results within the bounding area first
 */
- (void)forwardGeocoding:(NSString *)address
          limitCenterLat:(double)limitCenterLat
          limitCenterLng:(double)limitCenterLng
            limitSpanLat:(double)spanLat
            limitSpanLng:(double)spanLng
           limitToBounds:(BOOL)limitToBounds
                language:(NSString *)language
                 success:(void (^)(NSURLSessionDataTask *task, id responseObject, NSDictionary *places))success
                 failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure owner:(id)owner {
    
#ifdef DDLogInfo
    DDLogInfo(@"Forward geocoding: %@, lat %f, lng %f, spn-lat %f, spn-lng %f, limit %d", address, limitCenterLat, limitCenterLng, spanLat, spanLng, limitToBounds);
#else
    NSLog(@"Forward geocoding: %@, lat %f, lng %f, spn-lat %f, spn-lng %f, limit %d", address, limitCenterLat, limitCenterLng, spanLat, spanLng, limitToBounds);
#endif
    NSMutableDictionary* params = [@{
                                     @"geocode" : address,
                                     @"rspn" : limitToBounds ? @"1" : @"0",
                                     @"ll" : [NSString stringWithFormat: @"%.07f,%.07f", limitCenterLng, limitCenterLat],
                                     @"spn" : [NSString stringWithFormat: @"%.07f,%.07f", spanLng, spanLat]
                                     } mutableCopy];
    
    if (language != nil)
    {
        params[@"lang"] = language;
    }
    
    [self makeRequestWithParams: params success: success failure: failure owner: owner];
    
}

@end
