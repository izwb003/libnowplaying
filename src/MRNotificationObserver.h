#ifndef MRNotificationObserver_h
#define MRNotificationObserver_h

#import <Foundation/Foundation.h>
#import "typedefs.h"

@interface MRNotificationObserver : NSObject {
    CFBundleRef bundle;
    NowPlaying::MRMediaRemoteRegisterForNowPlayingNotificationsFunction MRMediaRemoteRegisterForNowPlayingNotifications;
    NowPlaying::MRMediaRemoteUnregisterForNowPlayingNotificationsFunction MRMediaRemoteUnregisterForNowPlayingNotifications;
}

@property (nonatomic, copy) void (^ _Nullable callback)(NSString * _Nullable notificationName, NSDictionary * _Nullable userInfo);

- (instancetype _Nullable )initWithCallback:(void (^_Nullable)(NSString * _Nullable notificationName, NSDictionary * _Nullable userInfo))callback;
- (void)startObserving;
- (void)stopObserving;

@end

#endif /* MRNotificationObserver_h */
