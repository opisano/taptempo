# Tap Tempo

Personal implementation of tap tempo.

## What is Tap Tempo?

It is a tool for finding out the beats per minute of a song. One can tap the space bar several times while listening to a song, and tap tempo will display the corresponding BPM value. 


## Build instructions 


### Compiler

The version of tap tempo is written in D so you need a D compiler to build it. I tested with LDC (LLVM D Compiler) v1.28, but it should also compile with GDC (GCC D Compiler) or DMD, provided the version is not too old. 

If you are using a Debian-based distribution, you may install a D compiler with the following command:

    sudo apt install ldc

or:

    sudo apt install gdc

For any other system, you can refer to [this page](https://dlang.org/download.html).


### Build system 

tap tempo uses Dub to build. Dub is the de-facto standard package management and build system for D project. Dub is easy to use and takes care of the dependencies for you. In this regard, Dub is very similar to Cargo for Rust, or npm for JavaScript. 

if you are using a Debian-based distribution, you may install Dub with the following command:

    sudo apt install dub

For any other system, you can refer to [this page](https://github.com/dlang/dub/releases).


### Dependencies 

The only dependencies you need on your system are:
 - sdl2
 - sdl2-mixer
 - sdl2-ttf 

If you are using a Debian-based distribution, you may install them with this command: 

    sudo apt install libsdl2-2.0-0 libsdl2-mixer-2.0-0 libsdl2-ttf-2.0-0

the various `*-dev` packages are not needed, since dub will fetch its own.

### Compiling 

In the project root directory, type

    dub build --build=release

You will need an internet connection, since Dub will try and download the D bindings to SDL 2.0.


## Features 

Taptempo can play a music file in the background, just provide a file name as the first command-line argument: 

    taptempo [path_to_music_file]

The file formats are the ones supported by SDL_Mixer:
 - WAV
 - OGG/Vorbis 
 - MP3
 - MIDI
 - MOD

## User manual

The two keyboard keys are used : 
 - The escape key closes the application
 - The space key is used to tap the tempo

That's all, folks