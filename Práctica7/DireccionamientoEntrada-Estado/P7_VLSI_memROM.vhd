library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity memROM is
	generic( --descripcion la estructura de la memoria
				addr_width : integer := 8; --# localidades
				addr_bits : integer := 3;
				data_width : integer := 14);
	port (	
				addr : in STD_LOGIC_VECTOR (addr_bits-1 downto 0);
				data : out STD_LOGIC_VECTOR (data_width-1 downto 0));
end memROM;

architecture Behavioral of memROM is

type rom_type is array (0 to addr_width-1) of
	STD_LOGIC_VECTOR (data_width-1 downto 0);
constant seg7 : rom_type := (
	"10101110000110",-- localidad  0 
	"00010010100100",-- localidad  1 
	"11111100011000",-- localidad  2 
	"01010100001000",-- localidad  3 
	"00000000010100",-- localidad  4 
	"00001001010110",-- localidad  5
	"00011011001110",-- localidad  6
	"00001001011001");--localidad  7

begin

data <= seg7(to_integer(unsigned(addr)));

end Behavioral;

