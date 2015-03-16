VGMPlay for MSX
===============

Copyright 2015 Laurens Holst

Thanks go to l_oliveira and popolon(fr) for support.

Project information
-------------------

Author: Laurens Holst <laurens.nospam@grauw.nl>  
Site: <https://bitbucket.org/grauw/vgmplay-msx>  
Issues: <https://bitbucket.org/grauw/vgmplay-msx/issues>  
Support: <http://www.msx.org/forum/msx-talk/software/vgmplay-msx>  
License: Simplified BSD License

Plays back VGM music files on MSX on the appropriate or emulated sound chips.

For more information on the VGM format see:
http://www.smspower.org/Music/VGMFileFormat

For a collection of VGM music see:
http://vgmrips.net/
http://www.smspower.org/Music/VGMs


System Requirements
-------------------

  * MSX, MSX2, MSX2+ or MSX turboR
  * 16kB video RAM
  * 128kB main RAM
  * MSX-DOS 2


Supported sound chips
---------------------

  * AY-3-8910 PSG / YM2149 SSG
  * YM2151 OPM (SFG-01/05)
  * YM2413 OPLL (MSX-MUSIC, FM-PAC)
  * YM3526 OPL (MSX-AUDIO, Music Module)
  * YM3812 OPL2 (MoonSound)
  * Y8950 MSX-AUDIO (Music Module, 256K sample RAM recommended)
  * K051649 Konami SCC
  * SN76489 DCSG (Franky, Playsoniq, Musical Memory Mapper)


Usage instructions
------------------

Run VGMPlay from MSX-DOS, specifying the VGM file as the first command line
argument.

Usage:

    vgmplay [options] <file.vgm>

The compressed VGZ format is not supported, rename the file to .vgm.gz and
extract it using gzip or your favourite decompression software to retrieve the
uncompressed VGM file.

Options:

  * /l  Number of playback loops. Default: 2.
    
    Many VGM music loops once the end of the song is reached. With this setting
    you can specify how many times VGMPlay should play the repeating part before
    exiting. The amount is specified like `/L15`. Use `/L` or `/L0` to loop
    infinitely. This setting will have no effect for songs which don’t loop.
    
  * /5  50 Hz screen frequency (V9938 and up only).
    
    The player’s internal timer currently runs in sync with the display
    frequency. For the best playback, the timer should match the playback
    frequency of the original source file. Because this is 60 Hz for most VGM
    files, by default VGMPlay switches to 60 Hz automatically. Use this option
    to override this behaviour in case the VGM file was recorded at 50 Hz or
    your monitor does not support 60 Hz.
    
  * /b  Enter blackout mode during playback.
    
    This setting makes the screen go black during playback. For machines with a
    lot of VDP interference on the audio output, this may reduce the amount of
    interference.


Development information
-----------------------

VGMPlay is free and open source software. If you want to contribute to the
project you are very welcome to. Please contact me at any one of the places
mentioned in the project information section.

You are also free to re-use code for your own projects, provided you abide by
the license terms.

Building the project with some of your own modifications is really easy on all
modern desktop platforms. On Mac OS X and Linux, simply invoke `make` to build
the binary and symbol files into the `bin` directory:

    make

Windows users can open the `Makefile` and build by pasting the line in the `all`
target into the Windows command prompt.

To launch the build in openMSX after building, put a copy of `MSXDOS2.SYS` and
`COMMAND2.COM` and some VGM files to test with in the `bin` directory, and then
invoke the `make run` command.

Note that the [glass](https://bitbucket.org/grauw/glass) assembler which is
embedded in the project requires [Java 7](http://java.com/getjava). To check
your Java version, invoke the `java -version` command.
