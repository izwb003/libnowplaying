#import "nowplaying.h"
#import "MRNowPlayingInfo.h"
#import "MRNotificationObserver.h"
#import "typedefs.h"
#import <Foundation/Foundation.h>

namespace NowPlaying {

MRNowPlayingInfoInterface* MRNowPlayingInfoInterface::Create() {
    return new MRNowPlayingInfo;
}

void MRNowPlayingInfoInterface::Delete(MRNowPlayingInfoInterface* instance) {
    delete instance;
    instance = 0;
}

MRNowPlayingInfo::MRNowPlayingInfo() {
    // Load MediaRemote.framework
    CFURLRef ref = (__bridge CFURLRef) [NSURL fileURLWithPath:@"/System/Library/PrivateFrameworks/MediaRemote.framework"];
    _bundle = CFBundleCreate(kCFAllocatorDefault, ref);
    
    MRMediaRemoteGetNowPlayingInfo = (MRMediaRemoteGetNowPlayingInfoFunction) CFBundleGetFunctionPointerForName(_bundle, CFSTR("MRMediaRemoteGetNowPlayingInfo"));
    
    update();
}

MRNowPlayingInfo::~MRNowPlayingInfo() {
    unregisterAutoUpdate();
    if (_bundle) {
        CFRelease(_bundle);
    }
}

void MRNowPlayingInfo::updateClientAppInfo(NSDictionary* userInfo) {
    [_clientAppInfoLock lock];
    _clientAppInfo.displayName = userInfo[@"kMRMediaRemoteNowPlayingApplicationDisplayNameUserInfoKey"];
    _clientAppInfo.pid = userInfo[@"kMRMediaRemoteNowPlayingApplicationPIDUserInfoKey"];
    [_clientAppInfoLock unlock];
}

void MRNowPlayingInfo::update() {
    update(nil);
}

void MRNowPlayingInfo::update(void (*callback)(MRNowPlayingInfoInterface*)) {
    MRMediaRemoteGetNowPlayingInfo(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(NSDictionary* information) {
        [_dataLock lock];
        if(information) _data = [information copy];
        else _data = 0;
        [_dataLock unlock];
        if(callback != nil) callback(this);
    });
}

int MRNowPlayingInfo::registerAutoUpdate() {
    return registerAutoUpdate(nil);
}

int MRNowPlayingInfo::registerAutoUpdate(void (*callback)(MRNowPlayingInfoInterface*)) {
    if(notificationObserver) return -1;
    notificationObserver = [[MRNotificationObserver alloc] initWithCallback: ^(NSString *notificationName, NSDictionary * userInfo) {
        if([notificationName isEqualToString:@"kMRMediaRemoteNowPlayingInfoDidChangeNotification"]) {
            updateClientAppInfo(userInfo);
            update(callback);
        }
    }];
    return 0;
}

bool MRNowPlayingInfo::isAutoUpdated() {
    if(notificationObserver) return true;
    else return false;
}

int MRNowPlayingInfo::unregisterAutoUpdate() {
    if(!notificationObserver) return -1;
    notificationObserver = 0;
    return 0;
}

bool MRNowPlayingInfo::hasInfo() {
    return (_data ? true : false);
}

NSDictionary* MRNowPlayingInfo::getRawInfo() {
    NSDictionary* ret = 0;
    [_dataLock lock];
    if(_data) ret = [_data copy];
    [_dataLock unlock];
    return ret;
}

char* MRNowPlayingInfo::getClientAppDisplayName() {
    char* ret = 0;
    [_clientAppInfoLock lock];
    ret = strdup([_clientAppInfo.displayName UTF8String]);
    [_clientAppInfoLock unlock];
    return ret;
}

int MRNowPlayingInfo::getClientAppPID() {
    int ret = 0;
    [_clientAppInfoLock lock];
    ret = [_clientAppInfo.pid intValue];
    [_clientAppInfoLock unlock];
    return ret;
}

char* MRNowPlayingInfo::getAlbumTitle() {
    char* ret = 0;
    [_dataLock lock];
    NSString* albumTitle = _data[@"kMRMediaRemoteNowPlayingInfoAlbum"];
    if(albumTitle) ret = strdup([albumTitle UTF8String]);
    [_dataLock unlock];
    return ret;
}

uint64_t MRNowPlayingInfo::getAlbumiTunesStoreAdamIdentifier() {
    uint64_t ret = 0;
    [_dataLock lock];
    NSNumber* adamIdentifier = _data[@"kMRMediaRemoteNowPlayingInfoAlbumiTunesStoreAdamIdentifier"];
    if(adamIdentifier) ret = [adamIdentifier unsignedLongLongValue];
    [_dataLock unlock];
    return ret;
}

char* MRNowPlayingInfo::getArtist() {
    char* ret = 0;
    [_dataLock lock];
    NSString* artist = _data[@"kMRMediaRemoteNowPlayingInfoArtist"];
    if(artist) ret = strdup([artist UTF8String]);
    [_dataLock unlock];
    return ret;
}

uint64_t MRNowPlayingInfo::getArtistiTunesStoreAdamIdentifier() {
    uint64_t ret = 0;
    [_dataLock lock];
    NSNumber* adamIdentifier = _data[@"kMRMediaRemoteNowPlayingInfoArtistiTunesStoreAdamIdentifier"];
    if(adamIdentifier) ret = [adamIdentifier unsignedLongLongValue];
    [_dataLock unlock];
    return ret;
}

char* MRNowPlayingInfo::getComposer() {
    char* ret = 0;
    [_dataLock lock];
    NSString* composer = _data[@"kMRMediaRemoteNowPlayingInfoComposer"];
    if(composer) ret = strdup([composer UTF8String]);
    [_dataLock unlock];
    return ret;
}

int MRNowPlayingInfo::getArtworkByteArray(uint8_t** data, size_t* length) {
    uint8_t* retData = 0;
    size_t retLength = 0;
    [_dataLock lock];
    NSData* artwork = _data[@"kMRMediaRemoteNowPlayingInfoArtworkData"];
    try {
        if(artwork) {
            retLength = [artwork length];
            if(retLength == 0) throw -1;
            retData = (uint8_t*)malloc(retLength);
            if(retData == NULL) throw -1;
            memcpy(retData, [artwork bytes], retLength);
            [_dataLock unlock];
            *data = retData;
            *length = retLength;
            return 0;
        }
        else throw -1;
    }
    catch(int) {
        [_dataLock unlock];
        *data = 0;
        *length = 0;
        return -1;
    }
}

char* MRNowPlayingInfo::getArtworkBase64() {
    char* ret = 0;
    [_dataLock lock];
    NSData* artwork = _data[@"kMRMediaRemoteNowPlayingInfoArtworkData"];
    if(artwork) {
        NSString* base64Str = [artwork base64EncodedStringWithOptions:0];
        ret = strdup([base64Str UTF8String]);
    }
    [_dataLock unlock];
    return ret;
}

int MRNowPlayingInfo::getArtworkHeight() {
    int ret = 0;
    [_dataLock lock];
    NSNumber* height = _data[@"kMRMediaRemoteNowPlayingInfoArtworkDataHeight"];
    ret = [height intValue];
    [_dataLock unlock];
    return ret;
}

int MRNowPlayingInfo::getArtworkWidth() {
    int ret = 0;
    [_dataLock lock];
    NSNumber* width = _data[@"kMRMediaRemoteNowPlayingInfoArtworkDataWidth"];
    ret = [width intValue];
    [_dataLock unlock];
    return ret;
}

char* MRNowPlayingInfo::getArtworkMIMEType() {
    char* ret = 0;
    [_dataLock lock];
    NSString* MIMEType = _data[@"kMRMediaRemoteNowPlayingInfoArtworkMIMEType"];
    if(MIMEType) ret = strdup([MIMEType UTF8String]);
    [_dataLock unlock];
    return ret;
}

char* MRNowPlayingInfo::getArtworkIdentifier() {
    char* ret = 0;
    [_dataLock lock];
    NSString* artworkIdentifier = _data[@"kMRMediaRemoteNowPlayingInfoArtworkIdentifier"];
    if(artworkIdentifier) ret = strdup([artworkIdentifier UTF8String]);
    [_dataLock unlock];
    return ret;
}

double MRNowPlayingInfo::getDuration() {
    double ret = 0.0;
    [_dataLock lock];
    NSString* duration = _data[@"kMRMediaRemoteNowPlayingInfoDuration"];
    if(duration) ret = [duration doubleValue];
    [_dataLock unlock];
    return ret;
}

double MRNowPlayingInfo::getElapsedTime() {
    double ret = 0.0;
    [_dataLock lock];
    NSString* elapsedTime = _data[@"kMRMediaRemoteNowPlayingInfoElapsedTime"];
    if(elapsedTime) ret = [elapsedTime doubleValue];
    [_dataLock unlock];
    return ret;
}

char* MRNowPlayingInfo::getGenre() {
    char* ret = 0;
    [_dataLock lock];
    NSString* genre = _data[@"kMRMediaRemoteNowPlayingInfoGenre"];
    if(genre) ret = strdup([genre UTF8String]);
    [_dataLock unlock];
    return ret;
}

bool MRNowPlayingInfo::isMusicApp() {
    bool ret = false;
    [_dataLock lock];
    NSNumber* isMusicApp = _data[@"kMRMediaRemoteNowPlayingInfoIsMusicApp"];
    if(isMusicApp) ret = [isMusicApp boolValue];
    [_dataLock unlock];
    return ret;
}

char* MRNowPlayingInfo::getMediaType() {
    char* ret = 0;
    [_dataLock lock];
    NSString* mediaType = _data[@"kMRMediaRemoteNowPlayingInfoMediaType"];
    if(mediaType) {
        NSString* mediaTypeSimplified = [mediaType substringFromIndex:22];  // 22 for enum prefix "MRMediaRemoteMediaType"
        ret = strdup([mediaTypeSimplified UTF8String]);
    }
    [_dataLock unlock];
    return ret;
}

int MRNowPlayingInfo::getPlaybackRate() {
    int ret = -1;
    [_dataLock lock];
    NSNumber* playbackRate = _data[@"kMRMediaRemoteNowPlayingInfoPlaybackRate"];
    if(playbackRate) ret = [playbackRate intValue];
    [_dataLock unlock];
    return ret;
}

int MRNowPlayingInfo::getQueueIndex() {
    int ret = 0;
    [_dataLock lock];
    NSNumber* queueIndex = _data[@"kMRMediaRemoteNowPlayingInfoQueueIndex"];
    if(queueIndex) ret = [queueIndex intValue];
    [_dataLock unlock];
    return ret;
}

int MRNowPlayingInfo::getTotalQueueCount() {
    int ret = 0;
    [_dataLock lock];
    NSNumber* totalQueueCount = _data[@"kMRMediaRemoteNowPlayingInfoTotalQueueCount"];
    if(totalQueueCount) ret = [totalQueueCount intValue];
    [_dataLock unlock];
    return ret;
}

int MRNowPlayingInfo::getTotalTrackCount() {
    int ret = 0;
    [_dataLock lock];
    NSNumber* totalTrackCount = _data[@"kMRMediaRemoteNowPlayingInfoTotalTrackCount"];
    if(totalTrackCount) ret = [totalTrackCount intValue];
    [_dataLock unlock];
    return ret;
}

time_t MRNowPlayingInfo::getTimestamp() {
    time_t ret = 0;
    [_dataLock lock];
    NSDate* timestamp = _data[@"kMRMediaRemoteNowPlayingInfoTimestamp"];
    if(timestamp) {
        NSTimeInterval interval = [timestamp timeIntervalSince1970];
        ret = (time_t)interval;
    }
    [_dataLock unlock];
    return ret;
}

char* MRNowPlayingInfo::getTitle() {
    char* ret = 0;
    [_dataLock lock];
    NSString* title = _data[@"kMRMediaRemoteNowPlayingInfoTitle"];
    if(title) ret = strdup([title UTF8String]);
    [_dataLock unlock];
    return ret;
}

int MRNowPlayingInfo::getTrackNumber() {
    int ret = 0;
    [_dataLock lock];
    NSNumber* trackNumber = _data[@"kMRMediaRemoteNowPlayingInfoTrackNumber"];
    if(trackNumber) ret = [trackNumber intValue];
    [_dataLock unlock];
    return ret;
}

char* MRNowPlayingInfo::getContentItemIdentifier() {
    char* ret = 0;
    [_dataLock lock];
    NSString* contentItemIdentifier = _data[@"kMRMediaRemoteNowPlayingInfoContentItemIdentifier"];
    if(contentItemIdentifier) ret = strdup([contentItemIdentifier UTF8String]);
    [_dataLock unlock];
    return ret;
}

uint64_t MRNowPlayingInfo::getUniqueIdentifier() {
    uint64_t ret = 0;
    [_dataLock lock];
    NSNumber* uniqueIdentifier = _data[@"kMRMediaRemoteNowPlayingInfoUniqueIdentifier"];
    if(uniqueIdentifier) ret = [uniqueIdentifier unsignedLongLongValue];
    [_dataLock unlock];
    return ret;
}

uint64_t MRNowPlayingInfo::getiTunesStoreIdentifier() {
    uint64_t ret = 0;
    [_dataLock lock];
    NSNumber* iTunesStoreIdentifier = _data[@"kMRMediaRemoteNowPlayingInfoiTunesStoreIdentifier"];
    if(iTunesStoreIdentifier) ret = [iTunesStoreIdentifier unsignedLongLongValue];
    [_dataLock unlock];
    return ret;
}

uint64_t MRNowPlayingInfo::getiTunesStoreSubscriptionAdamIdentifier() {
    uint64_t ret = 0;
    [_dataLock lock];
    NSNumber* iTunesStoreSubscriptionAdamIdentifier = _data[@"kMRMediaRemoteNowPlayingInfoiTunesStoreSubscriptionAdamIdentifier"];
    if(iTunesStoreSubscriptionAdamIdentifier) ret = [iTunesStoreSubscriptionAdamIdentifier unsignedLongLongValue];
    [_dataLock unlock];
    return ret;
}

MRNowPlayingInfoRepeatMode MRNowPlayingInfo::getRepeatMode() {
    MRNowPlayingInfoRepeatMode ret = kMRNowPlayingInfoRepeatModeUnknown;
    [_dataLock lock];
    NSNumber* mode = _data[@"kMRMediaRemoteNowPlayingInfoRepeatMode"];
    switch([mode intValue]) {
        case 1:
            ret = kMRNowPlayingInfoRepeatModeRepeatOff;
            break;
        case 2:
            ret = kMRNowPlayingInfoRepeatModeRepeatCurrent;
            break;
        case 3:
            ret = kMRNowPlayingInfoRepeatModeRepeatAll;
            break;
        default:
            ret = kMRNowPlayingInfoRepeatModeUnknown;
            break;
    }
    [_dataLock unlock];
    return ret;
}

MRNowPlayingInfoShuffleMode MRNowPlayingInfo::getShuffleMode() {
    MRNowPlayingInfoShuffleMode ret = kMRNowPlayingInfoShuffleModeUnknown;
    [_dataLock lock];
    NSNumber* mode = _data[@"kMRMediaRemoteNowPlayingInfoShuffleMode"];
    switch([mode intValue]) {
        case 1:
            ret = kMRNowPlayingInfoShuffleModeOff;
            break;
        case 3:
            ret = kMRNowPlayingInfoShuffleModeOn;
            break;
        default:
            ret = kMRNowPlayingInfoShuffleModeUnknown;
            break;
    }
    [_dataLock unlock];
    return ret;
}

};
