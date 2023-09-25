//
//  SignUpViewController.m
//  VSPFirebaseAuth
//
//  Created by Vivek Patel on 22/09/23.
//

#import "SignUpViewController.h"
#import "ProfileViewController.h"
#import "SceneDelegate.h"

@import FirebaseAuth;
@import FirebaseDatabase;
@import FirebaseStorage;

@interface SignUpViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

#pragma mark - Outlets
@property (weak, nonatomic) IBOutlet UIImageView *imgViewProfile;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITextField *txtConfirmPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtUsername;
@property (weak, nonatomic) IBOutlet UITextView *txtViewBIO;

@end

@implementation SignUpViewController

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    _imgViewProfile.layer.cornerRadius = _imgViewProfile.frame.size.width / 2;
    _imgViewProfile.clipsToBounds = true;
}

#pragma mark - Action
- (IBAction)actionSignup:(id)sender {
    if ([_txtEmail.text isEqualToString:@""]) {
        [self showAlert:@"Please enter email"];
    } else if ([_txtPassword.text isEqualToString:@""]) {
        [self showAlert:@"Please enter password"];
    } if (![_txtConfirmPassword.text isEqualToString:_txtPassword.text]) {
        [self showAlert:@"Password and confirm password should be same"];
    } else if ([_txtUsername.text isEqualToString:@""]) {
        [self showAlert:@"Please enter name"];
    } else if ([_txtViewBIO.text isEqualToString:@""]) {
        [self showAlert:@"Please add short bio"];
    } else {
        [_activityIndicator startAnimating];
        [[FIRAuth auth] createUserWithEmail:_txtEmail.text
                                   password:_txtPassword.text
                                 completion:^(FIRAuthDataResult * _Nullable authResult,
                                              NSError * _Nullable error) {
            if (error != nil) {
                [self->_activityIndicator stopAnimating];
                [self showAlert:error.localizedDescription];
            } else {
                [self uploadProfileImage: self->_imgViewProfile.image forUser: authResult.user];
            }
        }];
    }
}

#pragma mark - Convenience
- (void)uploadProfileImage:(UIImage *)image forUser:(FIRUser *)user {
    // Create a reference to Firebase Storage
    FIRStorageReference *storageRef = [[FIRStorage storage] reference];
    
    // Create a reference to store the image under the user's UID
    FIRStorageReference *imageRef = [storageRef child:[NSString stringWithFormat:@"profile_images/%@.jpg", user.uid]];
    
    // Convert the UIImage to data
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    
    // Upload the image data to Firebase Storage
    [imageRef putData:imageData metadata:nil completion:^(FIRStorageMetadata *metadata, NSError *error) {
        if (error) {
            NSLog(@"Error uploading profile image: %@", error.localizedDescription);
        } else {
            // Get the download URL for the uploaded image
            [imageRef downloadURLWithCompletion:^(NSURL *URL, NSError *error) {
                [self->_activityIndicator stopAnimating];
                if (error) {
                    NSLog(@"Error getting download URL: %@", error.localizedDescription);
                } else {
                    NSString *imageURL = [URL absoluteString];
                    // Store the imageURL in Firebase Realtime Database along with other user data (name, email, etc.)
                    [self storeUserDataInDatabaseWithName: self->_txtUsername.text email: self->_txtEmail.text imageURL: imageURL];
                    [[NSUserDefaults standardUserDefaults] setBool: true forKey:@"isLoggedIn"];
                    [self changeRootController];
                }
            }];
        }
    }];
}
- (void)storeUserDataInDatabaseWithName:(NSString *)name email:(NSString *)email imageURL:(NSString *)imageURL {
    FIRDatabaseReference *userRef = [[[FIRDatabase database] reference] child:@"users"];
    FIRDatabaseReference *ref = [userRef child:[FIRAuth auth].currentUser.uid];
    NSDictionary *userData = @{@"username": name, @"email": email, @"bio": _txtViewBIO.text, @"imageURL": imageURL};
    [ref setValue:userData];
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
-(void)showAlert: (NSString *)message {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Alert"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Action
- (IBAction)actionProfile:(UITapGestureRecognizer *)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

#pragma mark - Image Picker
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    UIImage *pickedImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    _imgViewProfile.image = pickedImage;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}
@end
