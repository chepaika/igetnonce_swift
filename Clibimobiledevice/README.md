# Clibimobiledevice

Swift wrapper for libimobiledevice.

For build do next:

``` shell
brew install libimobiledevice
brew install openssl
```

Next for build run in shell:

```PKG_CONFIG_PATH=/usr/local/opt/openssl@3/lib/pkgconfig swift build```

Or for building from Xcode create simlinks

```
ln  /usr/local/Cellar/openssl@3/3.0.1/lib/pkgconfig/openssl.pc /usr/local/lib/pkgconfig/openssl.pc
ln  /usr/local/Cellar/openssl@3/3.0.1/lib/pkgconfig/libcrypto.pc /usr/local/lib/pkgconfig/libcrypto.pc
ln  /usr/local/Cellar/openssl@3/3.0.1/lib/pkgconfig/libssl.pc /usr/local/lib/pkgconfig/libssl.pc
```

For more information about this WTF see [habr](https://habr.com/ru/post/651885/). But on russian :(
