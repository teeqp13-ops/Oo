#import "BYANOMenuViewController.h"
#import "ActivationConfig.h"
#import <UIKit/UIKit.h>

@interface BYANOMenuViewController ()
@property (nonatomic, strong) UITextField *keyTextField;
@property (nonatomic, strong) UIButton *activateButton;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) UISwitch *gpsSpoofSwitch;
@property (nonatomic, strong) UISwitch *deviceIDSpoofSwitch;
@property (nonatomic, strong) UISwitch *bluetoothSpoofSwitch;
@property (nonatomic, strong) UISwitch *jsonHookSwitch;
@property (nonatomic, strong) UIButton *hideMenuButton;
@end

@implementation BYANOMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.modalInPresentation = YES;
    self.view.backgroundColor = [UIColor colorWithRed:0.04 green:0.06 blue:0.12 alpha:1.0];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 55, self.view.bounds.size.width - 40, 40)];
    titleLabel.text = @"تفعيل BYANO";
    titleLabel.textColor = UIColor.whiteColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:26];
    [self.view addSubview:titleLabel];

    self.keyTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 115, self.view.bounds.size.width - 40, 48)];
    self.keyTextField.placeholder = @"أدخل كود التفعيل";
    self.keyTextField.textAlignment = NSTextAlignmentCenter;
    self.keyTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.keyTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.keyTextField.backgroundColor = [UIColor colorWithWhite:1 alpha:0.08];
    self.keyTextField.textColor = UIColor.whiteColor;
    self.keyTextField.layer.cornerRadius = 12;
    self.keyTextField.clipsToBounds = YES;
    self.keyTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"أدخل كود التفعيل" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithWhite:1 alpha:0.45]}];
    [self.view addSubview:self.keyTextField];

    self.activateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.activateButton.frame = CGRectMake(20, 176, self.view.bounds.size.width - 40, 48);
    self.activateButton.backgroundColor = [UIColor colorWithRed:0.10 green:0.45 blue:0.95 alpha:1.0];
    self.activateButton.layer.cornerRadius = 12;
    [self.activateButton setTitle:@"تفعيل الكود" forState:UIControlStateNormal];
    [self.activateButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.activateButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [self.activateButton addTarget:self action:@selector(activateKeyTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.activateButton];

    self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.loadingView.center = CGPointMake(self.view.bounds.size.width / 2.0, 247);
    self.loadingView.hidesWhenStopped = YES;
    [self.view addSubview:self.loadingView];

    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 262, self.view.bounds.size.width - 40, 42)];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.numberOfLines = 2;
    self.statusLabel.textColor = [UIColor colorWithWhite:1 alpha:0.7];
    self.statusLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:self.statusLabel];

    [self setupFeatureControls];

    NSString *savedCode = [[NSUserDefaults standardUserDefaults] stringForKey:BYANO_ACTIVATION_STORAGE_KEY];
    if (savedCode.length > 0) {
        self.keyTextField.text = savedCode;
    }
}

- (void)setupFeatureControls {
    NSArray<NSString *> *titles = @[@"GPS Spoofing", @"Device ID Spoofing", @"Bluetooth Spoofing", @"JSON Hooking"];
    NSMutableArray<UISwitch *> *switches = [NSMutableArray array];

    for (NSInteger index = 0; index < (NSInteger)titles.count; index++) {
        CGFloat y = 320 + (index * 52);
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 220, 32)];
        label.text = titles[(NSUInteger)index];
        label.textColor = UIColor.whiteColor;
        [self.view addSubview:label];

        UISwitch *toggle = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 72, y, 52, 32)];
        toggle.enabled = NO;
        [self.view addSubview:toggle];
        [switches addObject:toggle];
    }

    self.gpsSpoofSwitch = switches[0];
    self.deviceIDSpoofSwitch = switches[1];
    self.bluetoothSpoofSwitch = switches[2];
    self.jsonHookSwitch = switches[3];

    self.hideMenuButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.hideMenuButton.frame = CGRectMake(20, 540, self.view.bounds.size.width - 40, 44);
    [self.hideMenuButton setTitle:@"إخفاء القائمة" forState:UIControlStateNormal];
    [self.hideMenuButton addTarget:self action:@selector(hideMenuTapped) forControlEvents:UIControlEventTouchUpInside];
    self.hideMenuButton.enabled = NO;
    [self.view addSubview:self.hideMenuButton];
}

- (NSString *)deviceIdentifier {
    NSUUID *vendorIdentifier = [[UIDevice currentDevice] identifierForVendor];
    NSString *identifier = [vendorIdentifier UUIDString];
    return identifier.length > 0 ? identifier : @"unknown-device";
}

- (NSURL *)activationURL {
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BYANO_API_BASE_URL, BYANO_ACTIVATION_ENDPOINT];
    return [NSURL URLWithString:urlString];
}

- (NSDictionary *)activationPayloadForCode:(NSString *)code {
    NSString *deviceID = [self deviceIdentifier];
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier] ?: @"unknown";
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ?: @"1.0";

    return @{
        @"code": code,
        @"app": code,
        @"device_id": deviceID,
        @"device_uuid": deviceID,
        @"bundle_id": bundleID,
        @"app_version": appVersion,
        @"timestamp": @((NSInteger)[[NSDate date] timeIntervalSince1970])
    };
}

- (void)setLoading:(BOOL)loading message:(NSString *)message {
    self.activateButton.enabled = !loading;
    self.keyTextField.enabled = !loading;
    self.statusLabel.text = message;
    if (loading) {
        [self.loadingView startAnimating];
    } else {
        [self.loadingView stopAnimating];
    }
}

- (void)activateKeyTapped {
    NSString *apiKey = [self.keyTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (apiKey.length == 0) {
        self.statusLabel.text = @"يرجى إدخال كود التفعيل";
        return;
    }

    NSURL *url = [self activationURL];
    if (url == nil) {
        self.statusLabel.text = @"تعذر تكوين رابط الخادم";
        return;
    }

    NSError *bodyError = nil;
    NSData *body = [NSJSONSerialization dataWithJSONObject:[self activationPayloadForCode:apiKey] options:0 error:&bodyError];
    if (body == nil || bodyError != nil) {
        self.statusLabel.text = @"تعذر تجهيز طلب التفعيل";
        return;
    }

    [self setLoading:YES message:@"جاري التحقق من الكود..."];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.timeoutInterval = 25;
    request.HTTPBody = body;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:apiKey forHTTPHeaderField:@"X-API-Key"];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", apiKey] forHTTPHeaderField:@"Authorization"];
    [request setValue:[self deviceIdentifier] forHTTPHeaderField:@"X-Device-ID"];

    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setLoading:NO message:nil];

            if (error != nil) {
                self.statusLabel.text = [NSString stringWithFormat:@"تعذر الاتصال: %@", error.localizedDescription];
                return;
            }

            NSHTTPURLResponse *httpResponse = [response isKindOfClass:[NSHTTPURLResponse class]] ? (NSHTTPURLResponse *)response : nil;
            NSError *jsonError = nil;
            id jsonObject = data.length > 0 ? [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError] : nil;

            if (jsonError != nil) {
                self.statusLabel.text = @"استجابة الخادم ليست JSON صحيحة";
                self.statusLabel.textColor = [UIColor colorWithRed:1 green:0.35 blue:0.35 alpha:1.0];
                return;
            }

            NSDictionary *json = [jsonObject isKindOfClass:[NSDictionary class]] ? (NSDictionary *)jsonObject : nil;
            BOOL success = [json[@"success"] boolValue] ||
                           [json[@"active"] boolValue] ||
                           [json[@"valid"] boolValue] ||
                           [json[@"status"] isEqual:@"active"] ||
                           [json[@"status"] isEqual:@"success"];

            NSInteger statusCode = httpResponse != nil ? httpResponse.statusCode : 0;
            if (statusCode >= 200 && statusCode < 300 && success) {
                [[NSUserDefaults standardUserDefaults] setObject:apiKey forKey:BYANO_ACTIVATION_STORAGE_KEY];
                self.statusLabel.text = json[@"message"] ?: @"تم تفعيل الكود بنجاح";
                self.statusLabel.textColor = [UIColor colorWithRed:0.25 green:0.9 blue:0.5 alpha:1.0];
                self.gpsSpoofSwitch.enabled = YES;
                self.deviceIDSpoofSwitch.enabled = YES;
                self.bluetoothSpoofSwitch.enabled = YES;
                self.jsonHookSwitch.enabled = YES;
                self.hideMenuButton.enabled = YES;

                if (json[@"gps_enabled"] != nil) self.gpsSpoofSwitch.on = [json[@"gps_enabled"] boolValue];
                if (json[@"device_id_enabled"] != nil) self.deviceIDSpoofSwitch.on = [json[@"device_id_enabled"] boolValue];
                if (json[@"bluetooth_enabled"] != nil) self.bluetoothSpoofSwitch.on = [json[@"bluetooth_enabled"] boolValue];
                if (json[@"json_enabled"] != nil) self.jsonHookSwitch.on = [json[@"json_enabled"] boolValue];
            } else {
                NSString *message = [json[@"message"] isKindOfClass:[NSString class]] ? json[@"message"] : nil;
                self.statusLabel.text = message ?: [NSString stringWithFormat:@"فشل التفعيل (HTTP %ld)", (long)statusCode];
                self.statusLabel.textColor = [UIColor colorWithRed:1 green:0.35 blue:0.35 alpha:1.0];
            }
        });
    }];
    [task resume];
}

- (void)hideMenuTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
