
#import "MBLocationManager.h"
#import <MapKit/MapKit.h>

@implementation MBLocationManager

+ (instancetype)sharedInstance
{
    static MBLocationManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [MBLocationManager new];
    });
    return instance;
}

- (id)init
{
    if(self = [super init]) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = 400;
    }
    return self;
}

- (void)beginTrackingLocation
{
    [_locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if(error.code == kCLErrorDenied) {
        [_locationManager stopUpdatingLocation];
    } else if(error.code == kCLErrorLocationUnknown) {
        
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error retrieving location"
                                    message:[error description]
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

#define METERS_TO_MILES(X) X * .000621371

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = locations.lastObject;
    self.currentLocation = newLocation;
}

- (void)setCurrentLocation:(CLLocation *)currentLocation
{
    _currentLocation = currentLocation;
}

- (CGFloat)distanceInMilesFromCurrentLocationToLocation:(CLLocationCoordinate2D)locationCoordinates
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:locationCoordinates.latitude longitude:locationCoordinates.longitude];
    CLLocationDistance distance = [location distanceFromLocation:self.currentLocation];
    return METERS_TO_MILES(distance);
}

- (CGFloat)minutesForDistance:(CGFloat)distanceInMiles MPH:(CGFloat)speed
{
    CGFloat hours = distanceInMiles / speed;
    return hours * 60;
}

- (void)openMapsForLocation:(CLLocationCoordinate2D)coordinate name:(NSString*)name
{
    Class mapItemClass = [MKMapItem class];
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
    {
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        [mapItem setName:name];

        NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
        MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
        [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem] launchOptions:launchOptions];
    }
}

- (void)getCoordinatesForAddress:(NSString*)address completion:(void(^)(CLLocationCoordinate2D coords, NSError *error))completionBlock
{
    CLGeocoder *coder = [[CLGeocoder alloc] init];
    [coder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
        if(error) {
            completionBlock(CLLocationCoordinate2DMake(0, 0), error);
            return;
        }
        CLPlacemark *placemark = placemarks.lastObject;
        completionBlock(placemark.location.coordinate, nil);
    }];
}

@end