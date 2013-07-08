
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface MBLocationManager : NSObject <CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;

+ (instancetype)sharedInstance;

- (CGFloat)distanceInMilesFromCurrentLocationToLocation:(CLLocationCoordinate2D)locationCoordinates;
- (CGFloat)minutesForDistance:(CGFloat)distanceInMiles MPH:(CGFloat)speed;
- (void)openMapsForLocation:(CLLocationCoordinate2D)coordinate name:(NSString*)name;
@end
