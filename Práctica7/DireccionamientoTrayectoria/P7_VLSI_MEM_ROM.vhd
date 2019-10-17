library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MEM_ROM is

	--Estructura de la ROM
	generic(
		addr_width : integer := 40;
		addr_bits : integer := 6;
		data_width : integer := 9);
	
	port(
		addr : in STD_LOGIC_VECTOR(addr_bits - 1 downto 0);
		data : out STD_LOGIC_VECTOR(data_width - 1 downto 0));
		
end MEM_ROM;

architecture Behavioral of MEM_ROM is

	--Contenido de la ROM
	type rom_type is array(0 to addr_width - 1) of
		STD_LOGIC_VECTOR(data_width - 1 downto 0);
	constant mi_ROM : rom_type := (
		"001011010", --localidad 0
		"001011010", --localidad 1
		"011011100", --localidad 2
		"011011100", --localidad 3
		"001011010", --localidad 4
		"001011010", --localidad 5
		"011011100", --localidad 6
		"011011100", --localidad 7
		--
		"010001001", --localidad 8
		"010001001", --localidad 9
		"010001001", --localidad 10
		"010001001", --localidad 11
		"010001001", --localidad 12
		"010001001", --localidad 13
		"010001001", --localidad 14
		"010001001", --localidad 15
		--
		"001100110", --localidad 16
		"100000110", --localidad 17
		"001100110", --localidad 18
		"100000110", --localidad 19
		"001100110", --localidad 20
		"100000110", --localidad 21
		"001100110", --localidad 22
		"100000110", --localidad 23
		--
		"010000100", --localidad 24
		"010000100", --localidad 25
		"010000100", --localidad 26
		"010000100", --localidad 27
		"100000100", --localidad 28
		"100000100", --localidad 29
		"100000100", --localidad 30
		"100000100", --localidad 31
		--
		"000001010", --localidad 32
		"000001010", --localidad 33
		"000001010", --localidad 34
		"000001010", --localidad 35
		"000001010", --localidad 36
		"000001010", --localidad 37
		"000001010", --localidad 38
		"000001010"  --localidad 39
	);
		
begin

	data <= mi_ROM(to_integer(unsigned(addr)));

end Behavioral;