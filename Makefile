all:
	java -jar tools/glass.jar -I gen src/COM.asm bin/vgmplay.com bin/vgmplay.sym

package: all
	cp README.md LICENSE bin/
	rm -f bin/vgmplay.zip
	cd bin && zip vgmplay.zip vgmplay.rom README.md LICENSE

run: all
	openmsx -machine Panasonic_FS-A1GT -ext slotexpander -ext ide -ext Yamaha_SFG-05 -ext mbstereo -ext moonsound -ext Konami_Snatcher_Sound_Cartridge -script openmsx.tcl

run2: all
	openmsx -machine Yamaha_CX5MII -script openmsx.tcl

run3: all
	openmsx -machine Philips_NMS_8245 -ext slotexpander -ext slotexpander -ext ide -ext ram4mb -ext mbstereo -ext Yamaha_SFG-05 -ext moonsound -ext Konami_Snatcher_Sound_Cartridge -script openmsx.tcl
