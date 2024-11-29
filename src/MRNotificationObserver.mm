#import "MRNotificationObserver.h"
#import <Foundation/Foundation.h>

@implementation MRNotificationObserver

- (instancetype)initWithCallback:(void (^)(NSString *notificationName, NSDictionary * userInfo))callback {
    self = [super init];
    _callback = [callback copy];
    CFURLRef ref = (__bridge CFURLRef) [NSURL fileURLWithPath:@"/System/Library/PrivateFrameworks/MediaRemote.framework"];
    bundle = CFBundleCreate(kCFAllocatorDefault, ref);
    MRMediaRemoteRegisterForNowPlayingNotifications = (NowPlaying::MRMediaRemoteRegisterForNowPlayingNotificationsFunction) CFBundleGetFunctionPointerForName(bundle, CFSTR("MRMediaRemoteRegisterForNowPlayingNotifications"));
    MRMediaRemoteUnregisterForNowPlayingNotifications = (NowPlaying::MRMediaRemoteUnregisterForNowPlayingNotificationsFunction) CFBundleGetFunctionPointerForName(bundle, CFSTR("MRMediaRemoteUnregisterForNowPlayingNotifications"));
    [self startObserving];
    return self;
}

- (void)dealloc {
    [self stopObserving];
    if(bundle) CFRelease(bundle);
}

- (void)startObserving {
    MRMediaRemoteRegisterForNowPlayingNotifications(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onChange:)
                                                 name:@"kMRMediaRemoteNowPlayingInfoDidChangeNotification"
                                               object:nil];
}

- (void)stopObserving {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"kMRMediaRemoteNowPlayingInfoDidChangeNotification"
                                                  object:nil];
    MRMediaRemoteUnregisterForNowPlayingNotifications();
}

- (void)onChange:(NSNotification *)notification {
    self.callback(notification.name, notification.userInfo);
}

@end
