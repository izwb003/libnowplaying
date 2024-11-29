#ifndef typedefs_h
#define typedefs_h

#import <Foundation/Foundation.h>
#import "MRMediaRemoteCommands.h"

namespace NowPlaying {

typedef Boolean (*MRMediaRemoteSendCommandFunction)(MRMediaRemoteCommand cmd, NSDictionary* userInfo);
typedef void (*MRMediaRemoteSetElapsedTimeFunction)(double time);
typedef void (*MRMediaRemoteGetNowPlayingInfoFunction)(dispatch_queue_t queue, void (^handler)(NSDictionary* information));
typedef void (*MRMediaRemoteRegisterForNowPlayingNotificationsFunction)(dispatch_queue_t queue);
typedef void (*MRMediaRemoteUnregisterForNowPlayingNotificationsFunction)(void);

};

#endif /* typedefs_h */
