VGMPlay - VGM music file player for MSX
=======================================

Copyright 2013 Laurens Holst

Project information
-------------------

Author: Laurens Holst <laurens.nospam@grauw.nl>  
Site: <https://bitbucket.org/grauw/vgmplay>  
Issues: <https://bitbucket.org/grauw/vgmplay/issues>  
License: Simplified BSD License

Plays back VGM music files on MSX on the appropriate or emulated sound chips.

For more information on the VGM format see:
http://www.smspower.org/Music/VGMFileFormat

For a collection of VGM music see:
http://vgmrips.net/


System Requirements
-------------------

  * MSX, MSX2, MSX2+ or MSX turboR
  * 16kB video RAM
  * 64kB main RAM
  * MSX-DOS 2


Supported sound chips
---------------------

  * AY-3-8910 / YM2149 (PSG)

Support for more chips will be added in the future.


Usage instructions
------------------

Run VGMPlay from MSX-DOS, specifying the VGM file as the first command line
argument.

Usage:

    vgmplay filename.vgm

The compressed VGZ format is not supported, rename the file to .vgm.gz and
extract it using gzip or your favourite decompression software to retrieve the
uncompressed VGM file.


Development information
-----------------------

VGMPLAY is free and open source software. If you want to contribute to the
project you are very welcome to. Please contact me at any one of the places
mentioned in the project information section.

You are also free to re-use code for your own projects, provided you abide by
the license terms.

Label naming convention:

  * Constants: UPPERCASE
  * Variables: Class_variableName
  * Methods: Class_MethodName
  * Method-local labels: Class_MethodName_localName
