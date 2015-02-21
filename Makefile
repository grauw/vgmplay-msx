all:
	java -jar tools/glass.jar -I gen src/COM.asm bin/vgmplay.com bin/vgmplay.sym

package: all
	cp README.md LICENSE bin/
	rm -f bin/vgmplay.zip
	cd bin && zip vgmplay.zip vgmplay.rom README.md LICENSE

run: all
	openmsx -machine Panasonic_FS-A1GT -ext slotexpander -ext Yamaha_SFG-05 -script openmsx.tcl

run2: all
	openmsx -machine Yamaha_CX5MII -script openmsx.tcl
