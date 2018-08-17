# VideoPac-ZXDOS
Videopac / Odyssey 2 core for ZXDOS


This is a port of the Videopac fpga core to ZXDOS

This is a derivative work of the Original Mist project: http://ws0.org/tag/videopac/

Some code is borrowed from the ZX core of ZX-Uno http://zxuno.speccy.org


This core has VGA output. It supports PS/2 keyboard and two joysticks.

The Videopac cartridge ROMs are loaded from the SD card. There is a simple OSD that lets you select and load different ROMs (up to 65536 of them)

The OSD brings up by pressing TAB or the key above it in the keyboard. The number of the current ROM is displayed on the screen (in hexadecimal). You can go up and down to select a ROM with TAB and the key above it. After a few seconds without pressing any key, the displayed current ROM number will blink three times and then it will be loaded. Then the Videopac will be reset to execute it.

The ROM files are saved in the SD card in raw format. They must be 8 KBytes in length. If you have a rom of 2 or 4 KBytes you can repeat them to fill up to 8 KBytes. The roms are saved one after the another, up to 65536 ROMs.

If you load a ROM number that has not been written in the SD card, the videopac will not boot (but you can bring up again the OSD and choose another ROM)

If no SD card is present, the message "noSD" will be shown in red. You will have to insert the SD card and reset the machine in order to load the SD card.


Core ported by yomboprime 2018



=== ORIGINAL README: ===

This is the MiST port of Arnim Laeuger's implementation of a Videopac console

MiST port: 
http://ws0.org/tag/videopac/

Original source:
http://www.fpgaarcade.com/?q=node/14

Pong:
http://home.kpn.nl/rene_g7400/

As usual press F12 for the OSD menu and the right MiST button for reset.
