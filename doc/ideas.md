Ideas
=====

Multi-chip support:

  * 2x MSX-AUDIO / OPL on 0C0H and 0C2H, or MSX-AUDIO + OPL4

Fast forward key

Print notice about OPM when VGM format version is 1.01.

  * Better: pick OPLL or OPM by scanning first 1K of song data for OPM commands

Detect VGZ by file signature in stead of extension

VGZ background decompression

Show song length

  * Something like, Playing... 2:13 + 1:97
  * When infinite repeat is on: 2:13 + infinite
  * Next step: show current playback position

Chip emulations

  * Play OPLL on OPL4 (with current best known instrument settings)
  * Play PCM chips on OPL4 (C140, OKIM, and SegaPCM which is similar to OPL4)

Sparse MSX-AUDIO and OPL4 (AD)PCM loading

DOS1 support

Wildcard support

Playlist support (m3u)

Reset SFG-01/05 before playback

  * Had a case with noise playing during some songs due to lack of reset

Mute FM chips by setting ADSR to 0FH.

Reduce TPA usage (to allow selecting more files in Multi Mente)

  * Franky detection
  * PlaySoniq detection
  * MegaFlashROM PSG detection

Suspend VDP interrupts during vgz loading to improve performance

Do not load files which don’t fit into memory

Do not load files which can’t be played back on current sound chips

Add sound device priority and skip options
