#ifndef MRCommander_h
#define MRCommander_h

#import <Foundation/Foundation.h>
#import "nowplaying.h"
#import "typedefs.h"

namespace NowPlaying {

/**
 * The manager to communicate with the MediaRemote bundle to adjust the status of the currently playing media.
 * This allows you to control the media playing status of the system.
 *
 * Please ensure that your program will not terminate immediately after calling these operations.
 * The execution of these operations depends on some event design within macOS.
 * Therefore, it is best to use any event loop such as [NSApp run] to maintain the lifecycle of your program.
 *
 * For the case of multiple media playing simultaneously, this class can only interact with the active (last interaction with the user) one.
 * It cannot manipulate the inactive media.
 */
class MRCommander : public MRCommanderInterface {
private:
    
    CFBundleRef _bundle;
    
    MRMediaRemoteSendCommandFunction MRMediaRemoteSendCommand;
    MRMediaRemoteSetElapsedTimeFunction MRMediaRemoteSetElapsedTime;

public:

    MRCommander();

    ~MRCommander();

    /**
     * Ask MediaRemote to play the current playing media.
     *
     * @return The result of the call.
     */
    bool play();

    /**
     * Ask MediaRemote to pause the current playing media.
     *
     * @return The result of the call.
     */
    bool pause();

    /**
     * Ask MediaRemote to change the playing status of the current playing media.
     *
     * @return The result of the call.
     */
    bool togglePlayPause();

    /**
     * Ask MediaRemote to switch to next track.
     *
     * @return The result of the call.
     */
    bool nextTrack();

    /**
     * Ask MediaRemote to switch to previous track.
     *
     * @return The result of the call.
     */
    bool previousTrack();

    /**
     * Ask MediaRemote to seek to a time position of the current playing media.
     *
     * @param seekTime target position time (second).
     */
    void seekTo(double seekTime);
};

};

#endif /* MRCommander_h */
