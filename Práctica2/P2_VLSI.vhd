--Práctica 2: Registro de corrimiento.
--Equipo:
--Aceves Núñez Jonathan Gerardo
--Contreras Jiménez Sergio Brian
--Mora Magaña José David Divad
--Orozco Montes Zaid Andrés

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity princi is
    Port ( CLK : in  STD_LOGIC;--reloj de la fpga
			  RST : in  STD_LOGIC;--reset
           LED : out  STD_LOGIC_VECTOR (7 downto 0));--salida a los leds
end princi;

architecture Behavioral of princi is

signal conta : INTEGER range 0 to 64000000 := 0;--se usa para el divisor
signal divi : STD_LOGIC := '0';--el reloj ya dividido
signal sensores : STD_LOGIC_VECTOR (7 downto 0) := X"01";--señal auxiliar que sirve para mandar la salida

signal BAN : STD_LOGIC := '0';--bandera que indica la direccion en la que se mueve el bit, 1 para recorrerlo a la izquierda y 0 para la derecha
signal POS : INTEGER range 0 to 7 := 0; --posicion actual del bit
signal aux : INTEGER range -1 to 8 := 0; --auxiliar que indica la posicion siguiente del bit

begin

--divisor de frecuencia
process(CLK)
begin
	if rising_edge(CLK) then
		if(conta = 15999999) then
			conta <= 0;
			divi <= not divi;
		else 
			conta <= conta + 1;
		end if;
	end if;
end process;

--proceso de corrimiento
process(divi,RST,sensores)
begin
	--si el reset esta en '0' vuelve al estado inicial 00000001 y coloca las banderas en su estado incial
	if (RST = '0') then 
			sensores <= X"01";
			POS <= 0;
			BAN <= '0';
	else
		if rising_edge(divi) then
			--si ya recorrio el registro cambia el sentido para que lo recorra a la derecha y coloca el auxiliar a la derecha de POS
			if (POS = 7 and BAN = '1') then
				BAN <= '0';
				aux <= POS - 1;
			else
				--si ya recorrio el registro cambia el sentido para que lo recorra a la izquierda y coloca el auxiliar a la izquierda de POS
				if (POS = 0 and BAN = '0') then
					BAN <= '1';
					aux <= POS + 1;
				else 
					--si el sentido es hacia la derecha resta una posicion al auxiliar y a la posicion
					if (BAN = '0') then
						aux <= aux - 1;
						sensores(POS) <= '0';
						sensores (aux) <= '1';
						POS <= POS -1;
					--si el sentido es hacia la izquierda suma una posicion al auxiliar y a la posicion
					else 
						sensores(POS) <= '0';
						sensores(aux) <= '1';
						POS <= POS + 1;
						aux <= aux + 1;
					end if;
				end if;
			end if;
		end if;
	end if;
	LED <=(sensores);
end process;

end Behavioral;

