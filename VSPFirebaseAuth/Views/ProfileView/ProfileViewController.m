//
//  ProfileViewController.m
//  VSPFirebaseAuth
//
//  Created by Vivek Patel on 22/09/23.
//

#import "ProfileViewController.h"
#import "WeatherDetailViewController.h"
#import "WetaherDayTableViewCell.h"
#import "SceneDelegate.h"

@import FirebaseAuth;
@import FirebaseDatabase;
@import FirebaseStorage;
@import SDWebImage;


@interface ProfileViewController() <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

#pragma mark - Outlets
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewProfile;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblBio;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (weak, nonatomic) IBOutlet UITextField *txtCity;
@property (nonatomic, strong) NSDictionary *weatherData;
@end

@implementation ProfileViewController

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tblView.dataSource = self;
    self.tblView.delegate = self;
    _txtCity.text = @"Kolkata";
    _imgViewProfile.layer.cornerRadius = _imgViewProfile.frame.size.width / 2;
    _imgViewProfile.clipsToBounds = true;
    [self.navigationItem setHidesBackButton:YES animated:NO];
    [self setData];
    [self makeWeatherAPIRequest];
}

#pragma mark - Convenience
- (void)setData {
    NSString *userID = [FIRAuth auth].currentUser.uid;
    FIRDatabaseReference *userRef = [[[FIRDatabase database] reference] child:@"users"];
    FIRDatabaseReference *nameRef = [userRef child:userID];
    [nameRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        NSString *userName = snapshot.value[@"username"];
        self.lblName.text = userName;
        NSString *bio = snapshot.value[@"bio"];
        self.lblBio.text = bio;
        FIRStorageReference *storageRef = [[FIRStorage storage] reference];
        FIRStorageReference *imageRef = [storageRef child:[NSString stringWithFormat:@"profile_images/%@.jpg", userID]];
        [imageRef downloadURLWithCompletion:^(NSURL * _Nullable URL, NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error getting download URL: %@", error.localizedDescription);
            } else {
                NSString *imageURL = [URL absoluteString];
                [self.imgViewProfile sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:@"default_profile_image"]];
            }
        }];
    } withCancelBlock:^(NSError *error) {
        NSLog(@"Error fetching user's name: %@", error.localizedDescription);
    }];
}
- (void)makeWeatherAPIRequest {
    @autoreleasepool {
        NSString *apiKey = @"a0f797402ab447818340d10112513f3b";
        NSString *cityName = _txtCity.text;
        NSString *encodedCityName = [cityName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSString *urlString = [NSString stringWithFormat: @"https://api.weatherbit.io/v2.0/forecast/daily?city=%@&key=%@&days=7", encodedCityName, apiKey];
        NSURL *url = [NSURL URLWithString:urlString];
        [_activityIndicator startAnimating];
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error: %@", error.localizedDescription);
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.weatherData = nil;
                    [self.activityIndicator stopAnimating];
                    [self.tblView reloadData];
                });
                return;
            }
            
            NSError *jsonError;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (jsonError) {
                NSLog(@"JSON Error: %@", jsonError.localizedDescription);
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.weatherData = nil;
                    [self.activityIndicator stopAnimating];
                    [self.tblView reloadData];
                });
                return;
            }
            self.weatherData = json;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.activityIndicator stopAnimating];
                [self.tblView reloadData];
            });
            
        }];
        [task resume];
    }
}
-(void)changeRootController {
    UIWindow *window = [self.view window];
    if (window) {
        UIWindowScene *windowScene = window.windowScene;
        if (windowScene) {
            id<UIWindowSceneDelegate> delegate = (id<UIWindowSceneDelegate>)windowScene.delegate;
            if ([delegate isKindOfClass:[SceneDelegate class]]) {
                SceneDelegate *scenceDelegate = (SceneDelegate *)delegate;
                [scenceDelegate configureRootViewController];
            }
        }
    }
}

#pragma mark - Action
- (IBAction)actionLogout:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"isLoggedIn"];
    [self changeRootController];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.weatherData[@"data"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WetaherDayTableViewCell *cell = (WetaherDayTableViewCell *)[self.tblView dequeueReusableCellWithIdentifier:@"WetaherDayTableViewCell" forIndexPath:indexPath];
    NSDictionary *dayData = self.weatherData[@"data"][indexPath.row];
    cell.lblDate.text = dayData[@"valid_date"];
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Weather" bundle:nil];
    NSDictionary *dayData = self.weatherData[@"data"][indexPath.row];
    WeatherDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"WeatherDetailViewController"];
    vc.weatherData = dayData;
    [self.navigationController pushViewController:vc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

#pragma mark - TextField delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self makeWeatherAPIRequest];
    return YES;
}
@end
