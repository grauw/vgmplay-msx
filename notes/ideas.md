Ideas
=====

Options:

  * Wait n seconds before and after playing to prevent disk interference

Higher resolution clock

  * Line ints (MSX2 and up), OP* timers, R800 timer

Multi-chip support:

  * 2x PSG on MSX PSG + MegaFlashROM SCC+ SD
  * 2x MSX-AUDIO / OPL on 0C0H and 0C2H, or MSX-AUDIO + OPL4
  * 2x SN76489 support on MMM + Franky or 2x Playsoniq

Fast forward key

Print notice about OPM when VGM format version is 1.01.

  * Better: pick OPLL or OPM by scanning first 1K of song data for OPM commands

Detect gzip compression and show informative message.

Allocate memory in secondary mappers if primary mapper runs out.

VGZ decompression

  * Decompression after loading
  * Background decompression

Show song length

  * Something like, Playing... 2:13 + 1:97
  * When infinite repeat is on: 2:13 + infinite
  * Next step: show current playback position

Play OPLL songs on OPL4
