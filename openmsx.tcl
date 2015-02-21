ext debugdevice
set debugoutput stdout
debug set_watchpoint read_io 0x2E
#debug set_watchpoint write_mem 0x0000 {([debug read ioports 0xA8] & 0x0C) == 0x04}
#debug set_watchpoint read_mem 0x0000 {([debug read ioports 0xA8] & 0x0C) == 0x04}

ext ide
diskmanipulator create /tmp/vgmplay.dsk 16M
hda /tmp/vgmplay.dsk
diskmanipulator format hda
diskmanipulator import hda bin/

set throttle off
after time 14 "set throttle on"
after time 12 "type \"vgmplay sorcer37.vgm\\r\""
