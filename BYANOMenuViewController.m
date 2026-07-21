#import "BYANOMenuViewController.h"

@interface BYANOMenuViewController ()
@property (nonatomic, strong) UITextField *keyTextField;
@property (nonatomic, strong) UIButton *activateButton;
@property (nonatomic, strong) UISwitch *gpsSpoofSwitch;
@property (nonatomic, strong) UISwitch *deviceIDSpoofSwitch;
@property (nonatomic, strong) UISwitch *bluetoothSpoofSwitch;
@property (nonatomic, strong) UISwitch *jsonHookSwitch;
@property (nonatomic, strong) UIButton *hideMenuButton;
@end

@implementation BYANOMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Setup Key Text Field
    self.keyTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 100, self.view.frame.size.width - 40, 40)];
    self.keyTextField.placeholder = @"Enter wf_live_ key";
    self.keyTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.keyTextField];
    
    // Setup Activate Button
    self.activateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.activateButton.frame = CGRectMake(20, 150, self.view.frame.size.width - 40, 40);
    [self.activateButton setTitle:@"Activate Key" forState:UIControlStateNormal];
    [self.activateButton addTarget:self action:@selector(activateKeyTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.activateButton];
    
    // Setup GPS Spoof Switch
    UILabel *gpsLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 200, 200, 30)];
    gpsLabel.text = @"GPS Spoofing";
    [self.view addSubview:gpsLabel];
    self.gpsSpoofSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 70, 200, 0, 0)];
    [self.view addSubview:self.gpsSpoofSwitch];
    
    // Setup Device ID Spoof Switch
    UILabel *deviceIDLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 250, 200, 30)];
    deviceIDLabel.text = @"Device ID Spoofing";
    [self.view addSubview:deviceIDLabel];
    self.deviceIDSpoofSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 70, 250, 0, 0)];
    [self.view addSubview:self.deviceIDSpoofSwitch];
    
    // Setup Bluetooth Spoof Switch
    UILabel *bluetoothLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 300, 200, 30)];
    bluetoothLabel.text = @"Bluetooth Spoofing";
    [self.view addSubview:bluetoothLabel];
    self.bluetoothSpoofSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 70, 300, 0, 0)];
    [self.view addSubview:self.bluetoothSpoofSwitch];
    
    // Setup JSON Hook Switch
    UILabel *jsonHookLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 350, 200, 30)];
    jsonHookLabel.text = @"JSON Hooking";
    [self.view addSubview:jsonHookLabel];
    self.jsonHookSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 70, 350, 0, 0)];
    [self.view addSubview:self.jsonHookSwitch];
    
    // Setup Hide Menu Button
    self.hideMenuButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.hideMenuButton.frame = CGRectMake(20, 400, self.view.frame.size.width - 40, 40);
    [self.hideMenuButton setTitle:@"Hide Menu" forState:UIControlStateNormal];
    [self.hideMenuButton addTarget:self action:@selector(hideMenuTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.hideMenuButton];
}

- (void)activateKeyTapped {
    NSString *apiKey = self.keyTextField.text;
    if (apiKey.length == 0) {
        NSLog(@"API Key is empty");
        return;
    }

    NSString *urlString = [NSString stringWithFormat:@"https://key.p3nd.fun/api/settings.php?app=%@", apiKey];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    
    // Attempt to send the key in a custom header, as it's common for API keys
    [request setValue:apiKey forHTTPHeaderField:@"X-API-Key"];
    // Also try to send it as a Bearer token, another common method
    [request setValue:[NSString stringWithFormat:@"Bearer %@", apiKey] forHTTPHeaderField:@"Authorization"];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"API Request Error: %@", error.localizedDescription);
            dispatch_async(dispatch_get_main_queue(), ^{
                // Update UI on main thread
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:[NSString stringWithFormat:@"API Request Failed: %@", error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alert animated:YES completion:nil];
            });
            return;
        }

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200) {
            // Success, parse JSON response
            NSError *jsonError = nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (jsonError) {
                NSLog(@"JSON Parsing Error: %@", jsonError.localizedDescription);
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:[NSString stringWithFormat:@"JSON Parsing Failed: %@", jsonError.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                    [self presentViewController:alert animated:YES completion:nil];
                });
                return;
            }
            NSLog(@"API Response: %@", json);
            dispatch_async(dispatch_get_main_queue(), ^{
                // Update UI based on API response (e.g., enable/disable switches)
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success" message:@"API Key Activated!" preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alert animated:YES completion:nil];
                
                // Example: If API returns a 'gps_enabled' flag
                if (json[@"gps_enabled"]) {
                    self.gpsSpoofSwitch.on = [json[@"gps_enabled"] boolValue];
                }
                // ... similar logic for other switches
            });
        } else {
            // API returned an error status code
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"API Error - Status Code: %ld, Response: %@", (long)httpResponse.statusCode, responseString);
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"API Error" message:[NSString stringWithFormat:@"Status Code: %ld\nResponse: %@", (long)httpResponse.statusCode, responseString] preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alert animated:YES completion:nil];
            });
        }
    }];
    [dataTask resume];
}

- (void)hideMenuTapped {
    // Dismiss the view controller to hide the menu
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
