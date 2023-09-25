//
//  SignInViewController.m
//  VSPFirebaseAuth
//
//  Created by Vivek Patel on 22/09/23.
//

#import "SignInViewController.h"
#import "ProfileViewController.h"
#import "SceneDelegate.h"
@import FirebaseAuth;

@interface SignInViewController ()

#pragma mark - Outlets
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation SignInViewController

BOOL isValidEmail(NSString *email) {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}
#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - Action
- (IBAction)actionSignIn:(id)sender {
    
    if ([_txtEmail.text isEqualToString:@""]) {
        [self showAlert:@"Please enter email"];
    } else if (!isValidEmail(_txtEmail.text)) {
        [self showAlert:@"Please enter valid email"];
    } else if ([_txtPassword.text isEqualToString:@""]) {
        [self showAlert:@"Please enter password"];
    } else {
        [_activityIndicator startAnimating];
        [[FIRAuth auth] signInWithEmail:self->_txtEmail.text
                               password:self->_txtPassword.text
                             completion:^(FIRAuthDataResult * _Nullable authResult,
                                          NSError * _Nullable error) {
            [self.activityIndicator stopAnimating];
            if (error != nil) {
                [self showAlert: error.localizedDescription];
            } else {
                [[NSUserDefaults standardUserDefaults] setBool: true forKey:@"isLoggedIn"];
                [self changeRootController];
            }
        }];
    }
}

#pragma mark - Convenience
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
@end
