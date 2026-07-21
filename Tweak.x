#import <UIKit/UIKit.h>
#import "BYANOMenuViewController.h"

@interface UIApplication (BYANOMenuPresentation)
- (void)showBYANOMenu;
@end

static UIWindow *BYANOActiveKeyWindow(void) {
    for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if (![scene isKindOfClass:[UIWindowScene class]]) {
            continue;
        }

        UIWindowScene *windowScene = (UIWindowScene *)scene;
        if (windowScene.activationState != UISceneActivationStateForegroundActive) {
            continue;
        }

        for (UIWindow *window in windowScene.windows) {
            if (window.isKeyWindow) {
                return window;
            }
        }

        for (UIWindow *window in windowScene.windows) {
            if (!window.hidden && window.alpha > 0.0 && window.windowLevel == UIWindowLevelNormal) {
                return window;
            }
        }
    }

    return nil;
}

static UIViewController *BYANOTopViewController(UIViewController *controller) {
    UIViewController *current = controller;

    while (current.presentedViewController) {
        current = current.presentedViewController;
    }

    if ([current isKindOfClass:[UINavigationController class]]) {
        UIViewController *visible = ((UINavigationController *)current).visibleViewController;
        return visible ? BYANOTopViewController(visible) : current;
    }

    if ([current isKindOfClass:[UITabBarController class]]) {
        UIViewController *selected = ((UITabBarController *)current).selectedViewController;
        return selected ? BYANOTopViewController(selected) : current;
    }

    return current;
}

%hook UIApplication

- (void)didFinishLaunchingWithOptions:(id)options {
    %orig;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showBYANOMenu];
    });
}

%new
- (void)showBYANOMenu {
    UIWindow *window = BYANOActiveKeyWindow();
    UIViewController *presenter = BYANOTopViewController(window.rootViewController);

    if (!window || !presenter || [presenter isKindOfClass:[BYANOMenuViewController class]]) {
        return;
    }

    BYANOMenuViewController *menuVC = [[BYANOMenuViewController alloc] init];
    menuVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [presenter presentViewController:menuVC animated:YES completion:nil];
}

%end
