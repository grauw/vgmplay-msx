Ideas
=====

Multi-chip support:

  * 2x MSX-AUDIO / OPL on 0C0H and 0C2H, or MSX-AUDIO + OPL4
  * 2x SN76489 support on MMM + Franky or 2x Playsoniq

Fast forward key

Print notice about OPM when VGM format version is 1.01.

  * Better: pick OPLL or OPM by scanning first 1K of song data for OPM commands

VGZ background decompression

Show song length

  * Something like, Playing... 2:13 + 1:97
  * When infinite repeat is on: 2:13 + infinite
  * Next step: show current playback position

Chip emulations

  * Play OPLL on OPL4 (with current best known instrument settings)
  * Play OPL on VM2413 (a fallback option for OPL2?)
  * Play OPN family on OPM + PSG (though OPM misses the OPN’s SSG EG)
  * Play PCM chips on OPL4 (C140, OKIM, and SegaPCM which is similar to OPL4)

Sparse MSX-AUDIO and OPL4 (AD)PCM loading

DOS1 support

Wildcard support

Playlist support (m3u)

Reset SFG-01/05 before playback

  * Had a case with noise playing during some songs due to lack of reset

Mute FM chips by setting ADSR to 0FH.

Reduce TPA usage (to allow selecting more files in Multi Mente)

Show which drivers are playing which sound chips

  * Make distinction between SFG-01 and SFG-05
  * Franky detection
  * MegaFlashROM PSG detection

Detect SCC+ and support 5th channel
