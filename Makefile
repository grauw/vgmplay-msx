COPY_TARGET = /Volumes/MSXDOS2

all:
	mkdir -p bin
	java -jar tools/glass.jar -I gen src/COM.asm bin/vgmplay.com bin/vgmplay.sym

dist: all
	cp README.md CHANGES.md LICENSE bin/
	rm -f bin/vgmplay.zip
	cd bin && zip vgmplay.zip vgmplay.com README.md CHANGES.md LICENSE

copy: all
	cp bin/vgmplay.com $(COPY_TARGET)/
	diskutil umountDisk `mount | grep $(COPY_TARGET) | cut -d" " -f 1`

run: all
	openmsx -machine Panasonic_FS-A1GT -ext slotexpander -ext slotexpander -ext ide -ext Yamaha_SFG-05 -ext mbstereo -ext moonsound -ext Konami_Snatcher_Sound_Cartridge -ext ram1mb -script openmsx.tcl

run2: all
	openmsx -machine Yamaha_CX5MII -ext MegaFlashROM_SCC\+_SD -ext slotexpander -ext ram4mb -ext mbstereo -ext moonsound -ext Konami_Snatcher_Sound_Cartridge -script openmsx.tcl

run3: all
	openmsx -machine Philips_NMS_8245 -ext slotexpander -ext slotexpander -ext ide -ext ram4mb -ext mbstereo -ext Yamaha_SFG-05 -ext moonsound -ext Konami_Snatcher_Sound_Cartridge -script openmsx.tcl
