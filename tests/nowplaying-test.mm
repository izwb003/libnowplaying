#import "nowplaying.h"
#import <AppKit/AppKit.h>
#import <cstdio>

int main() {
    NowPlaying::MRNowPlayingInfoInterface* data = NowPlaying::MRNowPlayingInfoInterface::Create();
    NowPlaying::MRCommanderInterface* commander = NowPlaying::MRCommanderInterface::Create();
    
    data->registerAutoUpdate([](NowPlaying::MRNowPlayingInfoInterface* info) {
         printf("Information updated!\n");
        
         // Has info or not
         bool isInfoExists = info -> hasInfo();
         if(isInfoExists) printf("Now playing info exists! Details:\n");
         else printf("No media is being played now.\n");
         
         // Raw info
         NSDictionary* dict = info -> getRawInfo();
         // if(dict) NSLog([dict description]);
         
         // Album title
         char* albumTitle = info -> getAlbumTitle();
         printf("kMRMediaRemoteNowPlayingInfoAlbum: %s\n", albumTitle);
         free(albumTitle);   albumTitle = 0;
         
         // Album iTunes store adam identifier
         uint64_t albumiTunesStoreAdamIdentifer = info -> getAlbumiTunesStoreAdamIdentifier();
         printf("kMRMediaRemoteNowPlayingInfoAlbumiTunesStoreAdamIdentifier: %llu\n", albumiTunesStoreAdamIdentifer);
         
         // Artist
         char* artist = info -> getArtist();
         printf("kMRMediaRemoteNowPlayingInfoArtist: %s\n", artist);
         free(artist);       artist = 0;
         
         // Artist iTunes store adam identifier
         uint64_t artistiTunesStoreAdamIdentifier = info -> getArtistiTunesStoreAdamIdentifier();
         printf("kMRMediaRemoteNowPlayingInfoArtistiTunesStoreAdamIdentifier: %llu\n", artistiTunesStoreAdamIdentifier);
         
         // Composer
         char* composer = info -> getComposer();
         printf("kMRMediaRemoteNowPlayingInfoComposer: %s\n", composer);
         free(composer);     composer = 0;
         
         // Artwork
         uint8_t* artwork = 0;
         size_t artworkSize = 0;
         info -> getArtworkByteArray(&artwork, &artworkSize);
         char* artworkBase64 = info -> getArtworkBase64();
         int artworkHeight = info -> getArtworkHeight();
         int artworkWidth = info -> getArtworkWidth();
         char* artworkIdentifier = info -> getArtworkIdentifier();
         char* artworkMIMEType = info -> getArtworkMIMEType();
         // printf("kMRMediaRemoteNowPlayingInfoArtworkData: (%zu bytes) %s\n", artworkSize, artworkBase64);
         printf("kMRMediaRemoteNowPlayingInfoArtworkDataHeight: %d\n", artworkHeight);
         printf("kMRMediaRemoteNowPlayingInfoArtworkDataWidth: %d\n", artworkWidth);
         printf("kMRMediaRemoteNowPlayingInfoArtworkIdentifier: %s\n", artworkIdentifier);
         printf("kMRMediaRemoteNowPlayingInfoArtworkMIMEType: %s\n", artworkMIMEType);
         free(artwork);          artwork = 0;
         free(artworkBase64);    artworkBase64 = 0;
         free(artworkIdentifier);artworkIdentifier = 0;
         free(artworkMIMEType);  artworkMIMEType = 0;
         
         // Duration
         double duration = info -> getDuration();
         printf("kMRMediaRemoteNowPlayingInfoDuration: %lf\n", duration);
         
         // Elapsed time
         double elapsedTime = info -> getElapsedTime();
         printf("kMRMediaRemoteNowPlayingInfoElapsedTime: %lf\n", elapsedTime);
         
         // Genre
         char* genre = info -> getGenre();
         printf("kMRMediaRemoteNowPlayingInfoGenre: %s\n", genre);
         free(genre);    genre = 0;
         
         // Is music app
         bool isMusicApp = info -> isMusicApp();
         printf("kMRMediaRemoteNowPlayingInfoIsMusicApp: ");
         if(isMusicApp) printf("True\n");
         else printf("False\n");
         
         // Media type
         char* mediaType = info -> getMediaType();
         printf("kMRMediaRemoteNowPlayingInfoMediaType: %s\n", mediaType);
         free(mediaType);    mediaType = 0;
         
         // Playback rate
         int playbackRate = info -> getPlaybackRate();
         printf("kMRMediaRemoteNowPlayingInfoPlaybackRate: %d\n", playbackRate);
         
         // Queue index
         int queueIndex = info -> getQueueIndex();
         printf("kMRMediaRemoteNowPlayingInfoQueueIndex: %d\n", queueIndex);
         
         // Total queue count
         int totalQueueCount = info -> getTotalQueueCount();
         printf("kMRMediaRemoteNowPlayingInfoTotalQueueCount: %d\n", totalQueueCount);
         
         // Total track count
         int totalTrackCount = info -> getTotalTrackCount();
         printf("kMRMediaRemoteNowPlayingInfoTotalTrackCount: %d\n", totalTrackCount);
         
         // Timestamp
         time_t timestamp = info -> getTimestamp();
         printf("kMRMediaRemoteNowPlayingInfoTimestamp: %ld\n", timestamp);
         
         // Title
         char* title = info -> getTitle();
         printf("kMRMediaRemoteNowPlayingInfoTitle: %s\n", title);
         free(title);    title = 0;
         
         // Track number
         int trackNumber = info -> getTrackNumber();
         printf("kMRMediaRemoteNowPlayingInfoTrackNumber: %d\n", trackNumber);
         
         // Content item identifier
         char* contentItemIdentifier = info -> getContentItemIdentifier();
         printf("kMRMediaRemoteNowPlayingInfoContentItemIdentifier: %s\n", contentItemIdentifier);
         free(contentItemIdentifier);    contentItemIdentifier = 0;
         
         // Unique identifier
         uint64_t uniqueIdentifier = info -> getUniqueIdentifier();
         printf("kMRMediaRemoteNowPlayingInfoUniqueIdentifier: %llu\n", uniqueIdentifier);
         
         // iTunes store identifier
         uint64_t iTunesStoreIdentifier = info -> getiTunesStoreIdentifier();
         printf("kMRMediaRemoteNowPlayingInfoiTunesStoreIdentifier: %llu\n", iTunesStoreIdentifier);
         
         // iTunes store subscription adam identifier
         uint64_t iTunesStoreSubscriptionAdamIdentifier = info -> getiTunesStoreSubscriptionAdamIdentifier();
         printf("kMRMediaRemoteNowPlayingInfoiTunesStoreSubscriptionAdamIdentifier: %llu\n", iTunesStoreSubscriptionAdamIdentifier);
         
         // Repeat mode
         NowPlaying::MRNowPlayingInfoRepeatMode repeatMode = info -> getRepeatMode();
         printf("kMRMediaRemoteNowPlayingInfoRepeatMode: ");
         switch(repeatMode) {
             case NowPlaying::kMRNowPlayingInfoRepeatModeUnknown:
                 printf("Unknown\n");
                 break;
             case NowPlaying::kMRNowPlayingInfoRepeatModeRepeatOff:
                 printf("Off\n");
                 break;
             case NowPlaying::kMRNowPlayingInfoRepeatModeRepeatAll:
                 printf("Repeat all\n");
                 break;
             case NowPlaying::kMRNowPlayingInfoRepeatModeRepeatCurrent:
                 printf("Repeat current\n");
                 break;
         }
         
         // Shuffle mode
         NowPlaying::MRNowPlayingInfoShuffleMode shuffleMode = info -> getShuffleMode();
         printf("kMRMediaRemoteNowPlayingInfoShuffleMode: ");
         switch(shuffleMode) {
             case NowPlaying::kMRNowPlayingInfoShuffleModeUnknown:
                 printf("Unknown\n");
                 break;
             case NowPlaying::kMRNowPlayingInfoShuffleModeOff:
                 printf("Off\n");
                 break;
             case NowPlaying::kMRNowPlayingInfoShuffleModeOn:
                 printf("On\n");
                 break;
         }

        // Client app information
        char* clientAppDisplayName = info -> getClientAppDisplayName();
        int clientAppPID = info -> getClientAppPID();
        printf("Client app's display name: %s\n", clientAppDisplayName);
        printf("Client app's PID: %d\n", clientAppPID);
        free(clientAppDisplayName); clientAppDisplayName = 0;
    });
    
    // Emulates an event loop that keeps the program alive
    while(true) {
        // Also let's do something with it...
        commander->pause();
        printf("Media paused...\n");
        sleep(5);
        commander->play();
        printf("Media playing...\n");
        sleep(5);
        commander->previousTrack();
        printf("Playing previous track...\n");
        sleep(5);
        commander->nextTrack();
        printf("Playing next track...\n");
        sleep(5);
        commander->seekTo(1.0);
        printf("Seek to 1.0...\n");
        sleep(5);
    }
    
    // Just to remind you don't forget to delete them.
    NowPlaying::MRCommanderInterface::Delete(commander);
    NowPlaying::MRNowPlayingInfoInterface::Delete(data);
    
    return 0;
}
