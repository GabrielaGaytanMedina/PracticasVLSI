library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity READ is
    Port ( clk : in  STD_LOGIC;
           sw : in  STD_LOGIC_VECTOR (2 downto 0); --Orden: ABC
           rst : in  STD_LOGIC;
           leds : out  STD_LOGIC_VECTOR (5 downto 0);
           dply : out  STD_LOGIC_VECTOR (6 downto 0)); --Para saber en qué estado estamos
end READ;

architecture Behavioral of READ is

	signal edo_pres, edo_sig : STD_LOGIC_VECTOR(2 downto 0) := "000"; --Estados
	signal data : STD_LOGIC_VECTOR(8 downto 0); --Contenido de la memoria
	signal mem_addr : STD_LOGIC_VECTOR(5 downto 0); --Direcciones de la memoria
	signal conta : INTEGER range 0 to 64000000 := 0; --Variable auxiliar para un divisor de frecuencia
	signal divi : STD_LOGIC := '0'; --Nuevo reloj dividido

begin
	
	--Para conectar esta parte del código con el otro
	mi_ROM : entity work.MEM_ROM
	port map(addr => mem_addr, data => data);
	
	--Divisor de frecuencia
	process(clk)
		begin
			if(rising_edge(clk))then
				if(conta = 24999999) then
					conta <= 0;
					divi <= not divi;
				else
					conta <= conta + 1;
				end if;	
			end if;			
	end process;
	
	--Asiganación del estado siguiente y manejo de reset
	process(divi,rst)
		begin
			if(rst = '1') then
				edo_pres <= "000";
			elsif(rising_edge(divi)) then
				edo_pres <= edo_sig;
			end if;
	end process;
	
	--Se asigna un valor a la dirección. Esta depende
	--del estado presente y la entrada
	mem_addr(5 downto 3) <= edo_pres;
	mem_addr(2 downto 0) <= sw;
	
	--A partir del contenido de la memoria se obtienen
	--las salidas y el estado siguiente.
	edo_sig <= data(8 downto 6); --Los primeros 3 bits son para el estado siguiente
	leds <= data(5 downto 0); --Los demás bits son para la salida en los leds.
	--Orden de los leds: S0 S1 S2 S3 S4 S5
	
	--Proceso que muestra un número en un display
	--dependiendo del estado presente
	process(edo_pres)
		begin
			case edo_pres is
				when "000" =>
					dply <= "1000000";-- 0
				when "001" =>
					dply <= "1111001";-- 1
				when "010" =>
					dply <= "0100100";-- 2
				when "011" =>
					dply <= "0110000";-- 3
				when "100" =>
					dply <= "0011001";-- 4 
				when "101" =>
					dply <= "0010010";-- 5
				when "110" =>
					dply <= "0000010";-- 6
				when others =>
					dply <= "1111000";-- 7 
			end case;
			
	end process;

end Behavioral;