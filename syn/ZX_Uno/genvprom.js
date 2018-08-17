
var path = "./rom.bin";

var fs = require( 'fs' );

var output = 
"library ieee;\n" +
"use ieee.std_logic_1164.all;\n" +
"use ieee.numeric_std.all;\n" +
"\n" +
"entity rom_vp is\n" +
"  port (\n" +
"--    CLK         : in    std_logic;\n" +
"    A           : in    std_logic_vector(12 downto 0);\n" +
"    D           : out   std_logic_vector(7 downto 0)\n" +
"    );\n" +
"end;\n" +
"\n" +
"architecture RTL of rom_vp is\n" +
"\n" +
"\n" +
"  type ROM_ARRAY is array(0 to 8191) of std_logic_vector(7 downto 0);\n" +
"  constant ROM : ROM_ARRAY := (\n\n";

var fileBinary = fs.readFileSync( path );

if ( fileBinary.length > 8192 ) {
	console.error( "Error: File must be less or equal to 8 KBytes in length." );
	return;
}

var p = 0;
var p2 = 0;
for ( var i = 0; i < 1024; i++ ) {
	
	output += "    ";
	
	for ( var j = 0; j < 8; j++ ) {

		var hex = 'FF';
		//if ( ( ( p & 0x0FFF )  >= 1024 ) && ( ( p & 0x0FFF ) < 3072 ) ) {
		//if ( ( ( p & 0x0FFF )  >= 2048 ) ) {
		//if ( p < 4096 ) {
		//if ( ( ( p & 0x0FFF )  < 2048 ) ) {
		//if ( p < 4096 ) {
		
		//if ( ( ( p & 0x0FFF )  >= 2048 ) ) {
		//if ( p >= 3 * 2048 ) {

			hex = fileBinary[ p2 ].toString( 16 );

			p2++;
			
			if ( p2 >= fileBinary.length ) {
				p2 = 0;
			}

		//}
		p++;
		
		if ( hex.length < 2 ) {
			hex = "0" + hex;
		}

		output += "x\"" + hex + "\"";
		
		if ( j < 8 - 1 ) {
			output += ",";
		}
		
	}

	if ( i < 1024 - 1 ) {
		output += ",";
	}
	
	output += "\n";

}

output += "\n  );\n" +
"\n" +
"begin\n" +
"\n" +
"  p_rom : process\n" +
"  begin\n" +
"--    wait until rising_edge(CLK);\n" +
"     D <= ROM(to_integer(unsigned(A)));\n" +
"  end process;\n" +
"end RTL;\n" +
"";


fs.writeFileSync( "./rom_vp.vhd", output );
