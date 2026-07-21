#import <UIKit/UIKit.h>
#import "BYANOMenuViewController.h"

// Hooking into the application did finish launching to show our menu
%hook UIApplication

- (void)didFinishLaunchingWithOptions:(id)options {
    %orig;
    
    // Add a delay to ensure the UI is ready
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showBYANOMenu];
    });
}

%new
- (void)showBYANOMenu {
    BYANOMenuViewController *menuVC = [[BYANOMenuViewController alloc] init];
    UIWindow *keyWindow = nil;
    
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *window in ((UIWindowScene *)scene).windows) {
                    if (window.isKeyWindow) {
                        keyWindow = window;
                        break;
                    }
                }
            }
        }
    } else {
        keyWindow = [UIApplication sharedApplication].keyWindow;
    }
    
    if (keyWindow) {
        [keyWindow.rootViewController presentViewController:menuVC animated:YES completion:nil];
    }
}

%end
