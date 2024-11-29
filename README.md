# libnowplaying

A library inspired by [kirtan-shah/nowplaying-cli](https://github.com/kirtan-shah/nowplaying-cli),
used to obtain information and control the media being played on macOS.

With this library you can integrate the ability of obtaining media information and control media playback into your application.

**Disclaimer**: libnowplaying uses private frameworks, which may cause it to break with future macOS software updates, and it is not suitable for being intergrated into programs that need to be published on App Store.

Tested and working on macOS Sequoia 15.1 arm64. Should also work since Ventura.

## Usage

All usage has been clearly indicated in the code documentation. Refer to [tests/nowplaying-test.mm](/tests/nowplaying-test.mm) for example.

This library was designed using the C++ specification and exposed all data in C style, intended to separate you from system APIs and Objective-C. In this way, it can be more convenient for C or C++ programmers to use. If you are an Objective-C or Swift programmer, it is more suitable to communicate directly with the MediaRemote framework using the system API.

## References and Acknowledgements

- [kirtan-shah/nowplaying-cli](https://github.com/kirtan-shah/nowplaying-cli)
- [PrivateFrameworks/MediaRemote](https://github.com/PrivateFrameworks/MediaRemote)
- [dimitarnestorov/MusicBar](https://github.com/dimitarnestorov/MusicBar)
