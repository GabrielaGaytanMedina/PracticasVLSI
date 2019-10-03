library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pwm is
    Port ( ENTRADAS : in STD_LOGIC_VECTOR (4 downto 0);
			  CLK : in STD_LOGIC;
			  LED_B : out  STD_LOGIC_VECTOR (4 downto 0));
end pwm;

architecture Behavioral of pwm is

signal conta : INTEGER range 0 to 64000000 := 0;
signal div2,div4,div10 : std_logic;

begin

--divisor de frecuencia para generar los ciclos de trabajo
process(CLK)
begin
	if rising_edge(CLK) then
		if(conta = 100) then --para 1[MHz]
			conta <= 0;
		else 
			conta <= conta + 1;
		end if;
		
		--Para generar un ciclo de 25%
		if(conta <25) then
			div4 <= '1';
		else 
			div4 <= '0';
		end if;
		
		--para generar un ciclo de 50%
		if(conta < 50) then
			div2 <= '1';
		else
			div2 <= '0';
		end if;
		
		--para generar un ciclo de 10%
		if(conta < 10) then
			div10 <= '1';
		else
			div10 <= '0';
		end if;
	end if;
end process;

--Proceso de asignacion de salidas
process(ENTRADAS,div4,div10,div2)
begin
	--Para 10%
	if (ENTRADAS(0) = '1') then
		LED_B(0) <= div10;
	else
		LED_B(0) <= '0';
	end if;
	
	--Para 25%
	if (ENTRADAS(1) = '1') then
		LED_B(1) <= div4;
	else
		LED_B(1) <= '0';
	end if;
	
	--Para 50%
	if (ENTRADAS(2) = '1') then
		LED_B(2) <= div2;
	else
		LED_B(2) <= '0';
	end if;
	
	--Para 75%
	if (ENTRADAS(3) = '1') then
		LED_B(3) <= not(div4);
	else
		LED_B(3) <= '0';
	end if;
	
	--Para 90%
	if (ENTRADAS(4) = '1') then
		LED_B(4) <= not(div10);
	else
		LED_B(4) <= '0';
	end if;
end process;

end Behavioral;

