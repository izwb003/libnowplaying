#import "nowplaying.h"
#import "MRCommander.h"
#import "MRMediaRemoteCommands.h"
#import "typedefs.h"
#import <Foundation/Foundation.h>

namespace NowPlaying {

MRCommanderInterface* MRCommanderInterface::Create() {
    return new MRCommander;
}

void MRCommanderInterface::Delete(MRCommanderInterface* instance) {
    delete instance;
    instance = 0;
}

MRCommander::MRCommander() {
    // Load MediaRemote.framework
    CFURLRef ref = (__bridge CFURLRef) [NSURL fileURLWithPath:@"/System/Library/PrivateFrameworks/MediaRemote.framework"];
    CFBundleRef _bundle = CFBundleCreate(kCFAllocatorDefault, ref);

    MRMediaRemoteSendCommand = (MRMediaRemoteSendCommandFunction) CFBundleGetFunctionPointerForName(_bundle, CFSTR("MRMediaRemoteSendCommand"));
    MRMediaRemoteSetElapsedTime = (MRMediaRemoteSetElapsedTimeFunction) CFBundleGetFunctionPointerForName(_bundle, CFSTR("MRMediaRemoteSetElapsedTime"));
}

MRCommander::~MRCommander() {
    if (_bundle) {
        CFRelease(_bundle);
    }
}

bool MRCommander::play() {
    return MRMediaRemoteSendCommand(MRMediaRemoteCommandPlay, nil);
}

bool MRCommander::pause() {
    return MRMediaRemoteSendCommand(MRMediaRemoteCommandPause, nil);
}

bool MRCommander::togglePlayPause() {
    return MRMediaRemoteSendCommand(MRMediaRemoteCommandTogglePlayPause, nil);
}

bool MRCommander::nextTrack() {
    return MRMediaRemoteSendCommand(MRMediaRemoteCommandNextTrack, nil);
}

bool MRCommander::previousTrack() {
    return MRMediaRemoteSendCommand(MRMediaRemoteCommandPreviousTrack, nil);
}

void MRCommander::seekTo(double seekTime) {
    MRMediaRemoteSetElapsedTime(seekTime);
}

}
