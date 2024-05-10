** MAME + Emscripten
https://8bitworkshop.com/docs/posts/2020/compiling-emulators-to-webassembly-without-emscripten.html
https://web.archive.org/web/20230118110653/https://www.knoats.com/books/self-hosted-applications/page/mame-web-application
https://docslib.org/doc/10434231/mame-web-application
https://github.com/db48x/emularity

> git clone https://github.com/emscripten-core/emsdk.git
> cd emsdk
> source ./emsdk_env.sh
# latest clang 16 - 3.1.50 (compile error)
> ./emsdk install 3.1.25
> ./emsdk activate 3.1.25

> cd ..
> git clone https://github.com/mamedev/mame.git
> cd mame
> emmake make SOURCES=sinclair/scorpion.cpp,sinclair/tsconf.cpp,sinclair/sprinter.cpp,sinclair/spectrum.cpp,sinclair/spec128.cpp,sinclair/pentevo.cpp,sinclair/atm.cpp,sinclair/pentagon.cpp -j6
> python3 -m http.server 8080
# http://localhost:8080/mame.html
