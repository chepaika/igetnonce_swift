# igetnonce_swift

Rework of original [igetnonce](https://github.com/tihmstar/igetnonce) whith a greate thanks for [@tihmstar](https://github.com/tihmstar) on Swift

It's my first Swift project created for education purpose and fun))

Project contains all wrappers for required C libs, so may be also used as trampoline for another works

## Dependencies

Before build project you need to install some dependencies:

```shell
brew install libimobiledevice
brew install openssl
brew install libirecovery
```

And if you want to build it in Xcode, also add symlinks for openssl:

```shell
ln  `brew --prefix openssl`/lib/pkgconfig/openssl.pc /usr/local/lib/pkgconfig/openssl.pc
ln  `brew --prefix openssl`/lib/pkgconfig/libcrypto.pc /usr/local/lib/pkgconfig/libcrypto.pc
ln  `brew --prefix openssl`/lib/pkgconfig/libssl.pc /usr/local/lib/pkgconfig/libssl.pc
```

Or for shell building just specify PKG_CONFIG_PATH env

```shell
PKG_CONFIG_PATH=`brew --prefix openssl`/lib/pkgconfig swift build
```
