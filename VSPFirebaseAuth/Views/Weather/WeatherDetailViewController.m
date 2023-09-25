//
//  WeatherDetailViewController.m
//  VSPFirebaseAuth
//
//  Created by Vivek Patel on 23/09/23.
//

#import "WeatherDetailViewController.h"

@interface WeatherDetailViewController ()

#pragma mark -- Outlets
@property (weak, nonatomic) IBOutlet UILabel *lblWindSpped;
@property (weak, nonatomic) IBOutlet UILabel *lblHumidity;
@property (weak, nonatomic) IBOutlet UILabel *lblPressure;
@property (weak, nonatomic) IBOutlet UILabel *lblMaxTemp;
@property (weak, nonatomic) IBOutlet UILabel *lblMinTemp;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@end

@implementation WeatherDetailViewController

#pragma mark -- View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setData];
}

#pragma mark -- Conveniece
- (void)setData {
    if ([_weatherData count] != 0) {
        NSString *datetime = _weatherData[@"datetime"];
        NSLog(@"Datetime: %@", datetime);
        if (![datetime isEqualToString: @""]) {
            _lblDate.text = datetime;
        }
        NSString *windSpeed = _weatherData[@"wind_spd"];
        if (windSpeed != nil && [windSpeed isKindOfClass:[NSNumber class]]) {
            NSNumber *windSpeedNumber = (NSNumber *)windSpeed;
            // Convert the NSNumber to a string if needed
            NSString *windSpeed = [windSpeedNumber stringValue];
            _lblWindSpped.text =  [NSString stringWithFormat:@"%@ Km/h", windSpeed];
        }
        NSNumber *relativeHumidityNumber = _weatherData[@"rh"];
        if (relativeHumidityNumber != nil) {
            int relativeHumidity = [relativeHumidityNumber intValue];
            _lblHumidity.text = [NSString stringWithFormat:@"%d", relativeHumidity];
        }
        NSString *pressureString = _weatherData[@"pres"];
        if (pressureString != nil) {
            double pressure = [pressureString doubleValue];
            _lblPressure.text = [NSString stringWithFormat:@"%.1f hpa", pressure];
        }
        NSString *maxTempString = _weatherData[@"max_temp"];
        if (maxTempString != nil) {
            double maxTemp = [maxTempString doubleValue];
            _lblMaxTemp.text = [NSString stringWithFormat:@"%.1f Celcius", maxTemp];
        }
        NSString *minTempString = _weatherData[@"min_temp"];
        if (minTempString != nil) {
            double minTemp = [minTempString doubleValue];
            _lblMinTemp.text = [NSString stringWithFormat:@"%.1f Celcius", minTemp];
        }
        NSString *weatherDescription = _weatherData[@"weather"][@"description"];
        if (weatherDescription != nil && [weatherDescription isKindOfClass:[NSString class]]) {
            _lblDescription.text = [NSString stringWithFormat:@"%@", weatherDescription];
        }
    }
}
@end

