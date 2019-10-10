library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity miROM is
	generic( --descripcion la estructura de la memoria
				addr_width : integer := 16; --# localidades
				addr_bits : integer := 4;
				data_width : integer := 7);
	port (	
				addr : in STD_LOGIC_VECTOR (addr_bits-1 downto 0);
				data : out STD_LOGIC_VECTOR (data_width-1 downto 0));
end miROM;

architecture Behavioral of miROM is

type rom_type is array (0 to addr_width-1) of
	STD_LOGIC_VECTOR (data_width-1 downto 0);
signal seg7 : rom_type := (
	"1000001",-- localidad  0 (U)
	"1000111",-- localidad  1 (L)
	"0010010",-- localidad  2 (S)
	"1001111",-- localidad  3 (I)
	"0111111",-- localidad  4 (-)
	"0100100",-- localidad  5 (2)
	"1000000",-- localidad  6 (0)
	"0100100",-- localidad  7 (2)
	"1000000",-- localidad  8 (0)
	"1110111",-- localidad  9 (_)
	"1111001",-- localidad 10 (1)
	"0111111",-- localidad 11 (-)
	"1100001",-- localidad 12 (J)
	"0000011",-- localidad 13 (b)
	"0100001",-- localidad 14 (d)
	"0001000");--localidad 15 (A)

begin

data <= seg7(to_integer(unsigned(addr)));

end Behavioral;

