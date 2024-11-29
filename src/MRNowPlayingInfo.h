#ifndef MRNowPlayingInfo_h
#define MRNowPlayingInfo_h

#import <Foundation/Foundation.h>
#import "nowplaying.h"
#import "typedefs.h"
#import "MRNotificationObserver.h"

namespace NowPlaying {

/**
 * The info of the now playing media registered to MediaRemote.
 *
 * Not all the information can be get from this class. Sometimes the system doesn't know some information, neither.
 * For this condition getting these information may return invalid values. See the documentation of corresponding methods.
 * All these information represent what does the system learned from the application. In some applications some params may have different meanings.
 *
 * For the case of multiple media playing simultaneously, this class can only obtain information about the currently active (last interacted with the user) media.
 * It cannot obtain the information about the inactive media.
 *
 * The data in the system will be updated when the playing status changes. You must call update() manually to get the latest information from the system.
 * This will affect the retrieval of some information such as elapsedTime or timestamp. See their descriptions for more information.
 *
 * Please be careful with C style data. Most of the getters return a copy of real data, so you have to free them manually.
 */
class MRNowPlayingInfo : public MRNowPlayingInfoInterface {
private:
    
    CFBundleRef _bundle;
    MRMediaRemoteGetNowPlayingInfoFunction MRMediaRemoteGetNowPlayingInfo;
    MRNotificationObserver* notificationObserver = 0;
    
    NSDictionary* _data;
    NSLock* _dataLock = [[NSLock alloc] init];
    
    struct {
        NSString* displayName = @"";
        NSNumber* pid = 0;
    } _clientAppInfo;
    NSLock* _clientAppInfoLock = [[NSLock alloc] init];
    void updateClientAppInfo(NSDictionary* userInfo);
    
public:
    
    MRNowPlayingInfo();
    
    ~MRNowPlayingInfo();
    
    /**
     * Get the latest information from the system.
     * Should be called manually when information was changed.
     * Will be called automatically during initialization.
     *
     * @note
     * This method communicates asynchronously with the system API.
     * You may need to wait for the system to send back updated information after calling this method.
     * Therefore, you program may need an event loop like [NSApp run].
     */
    void update();
    
    /**
     * Get the latest information from the system, and call `callback` after completed.
     * Should be called manually when information was changed.
     *
     * @param callback The callback function to run after info updated.
     * @note
     * This method communicates asynchronously with the system API.
     * You may need to wait for the system to send back updated information after calling this method.
     * Your `callback` function will be executed in the system global dispatch queue (in brief, another thread hosted by system).
     * Therefore, you program may need an event loop like [NSApp run].
     */
    void update(void (*callback)(MRNowPlayingInfoInterface*));
    
    /**
     * Register system notification events to automatically update data when the system now playing information updates.
     * Each MRNowPlayingInfo instance can only register once. Calling this method again after registeration will cause error.
     *
     * @return 0 for success, -1 for already registered.
     */
    int registerAutoUpdate();
    
    /**
     * Register system notification events to automatically update data when the system now playing information updates,
     * and call `callback` after each update.
     * Each MRNowPlayingInfo instance can only register once. Calling this method again after registeration will cause error.
     *
     * @param callback The callback function to run after each update. It will be executed in the system dispatch queue.
     * @return 0 for success, -1 for already registered.
     */
    int registerAutoUpdate(void (*callback)(MRNowPlayingInfoInterface*));
    
    /**
     * Get to know whether this MRNowPlayingInfo instance has been registered to update information automatically or not.
     *
     * @return true for this MRNowPlayingInfo instance will update automatically, false for will not.
     */
    bool isAutoUpdated();
    
    /**
     * Unregister this MRNowPlayingInfo instance from updating information automatically.
     *
     * @return 0 for success, -1 for this instance was not registered to update information automatically.
     */
    int unregisterAutoUpdate();
    
    /**
     * Get to know whether the system knows something about the media playing now or not.
     *
     * @return true for now playing info exists, false for not (often because no music app is running).
     */
    bool hasInfo();
    
    /**
     * Get the information in raw NSDictionary format.
     *
     * @return A pointer to a NSDictionary which contains raw now playing info. NULL if no info (often because no music app is running).
     * @warning Please note that you received a copy of real data. Remember to free it if without ARC.
     */
    NSDictionary* getRawInfo();
    
    /**
     * Get the display name of the application playing the media.
     *
     * @note
     * Currently this information can only be obtained when using \ref registerAutoUpdate().
     * It will be empty if calling \ref update() manually.
     *
     * @todo Try making manually update also available to get this info.
     *
     * @warning You received a copy of real data. Remember to free the return value after using it.
     * @return UTF-8 C style string describes the name of the application playing the media. Empty if unknown.
     */
    char* getClientAppDisplayName();
    
    /**
     * Get the PID of the application playing the media.
     *
     * @note
     * Currently this information can only be obtained when using \ref registerAutoUpdate().
     * It will be 0 if calling \ref update() manually.
     *
     * @todo Try making manually update also available to get this info.
     *
     * @return The PID of the application playing the media. 0 if unknown.
     */
    int getClientAppPID();
    
    /**
     * Get the title of the album.
     *
     * @warning You received a copy of real data. Remember to free the return value after using it.
     * @return UTF-8 C style string of the album title. NULL if no data.
     */
    char* getAlbumTitle();
    
    /**
     * Get the adam identifier of the album in iTunes store.
     * May be used to uniquely identify the album.
     * Only appears when using system music app.
     *
     * @return the adam identifier number of the album in iTunes store. 0 for unknown.
     */
    uint64_t getAlbumiTunesStoreAdamIdentifier();
    
    /**
     * Get the name of the artist.
     *
     * @warning You received a copy of real data. Remember to free the return value after using it.
     * @return UTF-8 C style string of the artist's name. NULL if no data.
     */
    char* getArtist();
    
    /**
     * Get the adam identifier of the artist in iTunes store.
     * May be used to uniquely identify the artist.
     * Only appears when using system music app.
     *
     * @return the adam identifer number of the artist in iTunes store. 0 for unknown.
     */
    uint64_t getArtistiTunesStoreAdamIdentifier();
    
    /**
     * Get the name of composer(s).
     *
     * @warning You received a copy of real data. Remember to free the return value after using it.
     * @return UTF-8 C style string of the composer(s)' name. NULL if no data.
     */
    char* getComposer();
    
    /**
     * Get the artwork of the album, in C style byte array.
     * Call \ref getArtworkMIMEType() to know its format. Mostly it will be ```image/jpeg```.
     *
     * @param data Modify the pointer to point to a copied C style byte array containing artwork data. NULL if no data.
     * \warning You received a copy of real data. Remember to free it after using it.
     * @param length Modify the pointer to indicate the length of `data`, in bytes. 0 if no data.
     * @return 0 for success, -1 for no data.
     */
    int getArtworkByteArray(uint8_t** data, size_t* length);
    
    /**
     * Get the artwork image of the album, in C style base64 encoded string.
     * Call \ref getArtworkMIMEType() to know its format. Mostly it will be ```image/jpeg```.
     *
     * @warning You received a copy of real data. Remember to free the return value after using it.
     * @return C style string that contains UTF-8 base64 encoded artwork data. NULL if no data.
     */
    char* getArtworkBase64();
    
    /**
     * Get the height of the artwork image. 0 for no data.
     *
     * @return The height of the artwork, in px.
     */
    int getArtworkHeight();
    
    /**
     * Get the width of the artwork image. 0 for no data.
     *
     * @return The width of the artwork, in px.
     */
    int getArtworkWidth();
    
    /**
     * Get the MIME type of the artwork image to know its format.
     * Mostly it will be ```image/jpeg```.
     *
     * @warning You received a copy of real data. Remember to free the return value after using it.
     * @return UTF-8 C style string that describes the MIME type of the artwork. NULL for no data or unknown.
     */
    char* getArtworkMIMEType();
    
    /**
     * Get the identifier of the artwork.
     * May be used to uniquely identify the artwork.
     *
     * @warning You received a copy of real data. Remember to free the return value after using it.
     * @return UTF-8 C style string that records the identifier of the artwork. NULL for unknown.
     */
    char* getArtworkIdentifier();
    
    /**
     * Get the total duration of the media playing now.
     *
     * @return The total duration (seconds) of the media playing now.
     */
    double getDuration();
    
    /**
     * Get the time being played (elapsed time) of the media playing now.
     *
     * @note
     * This info will not be updated in real-time.
     * In most cases, it represents the elapsed time at the moment when the playing status last changed.
     * That is, the elapsed time at the moment represented by \ref getTimestamp().
     * Therefore, repeatedly calling \ref update() to expect this data to be updated will not work.
     * To get real-time elapsed time, it's better to call \ref getTimestamp() to find out when the play status changed,
     * record the elapsed time at that moment, and calculate with the time now.
     * @return The elapsed time (seconds) of the media playing now.
     */
    double getElapsedTime();
    
    /**
     * Get the genre of the music playing now. returns NULL if unknown.
     *
     * @warning You received a copy of real data. Remember to free the return value after using it.
     * @return UTF-8 C style string that shows the genre of the music playing now. NULL if unknown.
     */
    char* getGenre();
    
    /**
     * Get to know that whether the media is being played by system music app or not.
     *
     * @return True if the media is being played with the system music app. Otherwise false.
     */
    bool isMusicApp();
    
    /**
     * Get the playing media's type.
     *
     * @warning You received a copy of real data. Remember to free the return value after using it.
     * @return A word which describes the media type, in UTF-8 C style string. NULL if unknown.
     */
    char* getMediaType();
    
    /**
     * Get the playback rate. 1 as playing (normally), 0 as paused, -1 as unknown. May have other values.
     *
     * @return Playback rate of the media playing now.
     */
    int getPlaybackRate();
    
    /**
     * Get the index of the media in the queue.
     *
     * @note Some application (even system music app) will not update this number and it may always be 0.
     * @return The index of the media in the queue.
     */
    int getQueueIndex();
    
    /**
     * Get the total count of media(s) in the queue.
     *
     * @note Some application (even system music app) will not update this number and it may always be 1.
     * @return The total count of media(s) in the queue.
     */
    int getTotalQueueCount();
    
    /**
     * Get the total count of tracks.
     *
     * @note Some application (even system music app) will not update this number and it may always be 0.
     * @return The total count of tracks.
     */
    int getTotalTrackCount();
    
    /**
     * Get the timestamp of when the playing status changed.
     * May be used to calculate the duration of the media played.
     *
     * @note
     * "when the playing status changed" means events like toggle play/pause, switch tracks, seek the progress manually, etc., either automatically or manually.
     * At this moment all playing status recorded in the system will be updated.
     * @return C style UNIX timestamp represents the time of when the playing status changed. 0 for unknown.
     */
    time_t getTimestamp();
    
    /**
     * Get the title of the media playing now.
     *
     * @warning You received a copy of real data. Remember to free the return value after using it.
     * @return The title of the playing media, in UTF-8 C style string.
     */
    char* getTitle();
    
    /**
     * Get the current playing track's number (in its album).
     *
     * @return The current playing track's number.
     */
    int getTrackNumber();
    
    /**
     * Get the identifier of the content item.
     * May be used to identify the content item.
     *
     * @warning You received a copy of real data. Remember to free the return value after using it.
     * @return The identifier of the content item. NULL if unknown.
     */
    char* getContentItemIdentifier();
    
    /**
     * Get the unique identifier of the info at this moment.
     * Will be updated when playing status changed, that is, will be updated at the moment of \ref getTimeStamp().
     * May be used to seperate the info.
     *
     * @return The unique identifier of the now playing info. 0 for unknown.
     */
    uint64_t getUniqueIdentifier();
    
    /**
     * Get the identifier of what's being played in iTunes store.
     *
     * @return The identifier of the content in iTunes store. 0 for unknown.
     */
    uint64_t getiTunesStoreIdentifier();
    
    /**
     * Get the adam identifier of the subscription in iTunes store.
     *
     * @return The adam identifier of the subscription in iTunes store. 0 for unknown.
     */
    uint64_t getiTunesStoreSubscriptionAdamIdentifier();
    
    /**
     * Get the player's repeat mode.
     *
     * @note
     * Modifying this information by the user will not cause the system to change the playback status.
     * That is to say,  when the user changes repeat mode, The now playing information will not be updated in the system.
     * The changed status will be updated together with the next system update of the playback status.
     * @return The repeat mode of the player.
     */
    MRNowPlayingInfoRepeatMode getRepeatMode();
    
    /**
     * Get the player's shuffle mode.
     *
     * @note
     * Modifying this information by the user will not cause the system to change the playback status.
     * That is to say,  when the user changes repeat mode, The now playing information will not be updated in the system.
     * The changed status will be updated together with the next system update of the playback status.
     * @return The shuffle mode of the player.
     */
    MRNowPlayingInfoShuffleMode getShuffleMode();
};

};

#endif /* MRNowPlayingInfo_h */
