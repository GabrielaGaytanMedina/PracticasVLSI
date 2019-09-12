--Pr�ctica 3: M�quinas de estados finitos(FSM), m�quina de Moore.
--Equipo:
--Aceves N��ez Jonathan Gerardo
--Contreras Jim�nez Sergio Brian
--Mora Maga�a Jos� David Divad
--Orozco Montes Zaid Andr�s

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity P3_VLSI is
    Port ( H : in  STD_LOGIC;
           MCLK : in  STD_LOGIC;
           A : out  STD_LOGIC;
           B : out  STD_LOGIC);
end P3_VLSI;

architecture Behavioral of P3_VLSI is

	type estado is (E0,E1,E2,E3); --descripci�n de m�quina de estados.
	signal qt : estado; --se�al para estado siguiente de tabla de transiciones.
	
begin
	process(MCLK) --proceso para cambio de estados en tanque.
		begin 
			if rising_edge(MCLK) then
				case qt is
					when E0 => --tanque lleno en inicio, bombas apagadas.
						A <= '0';	--se puede observar como las salidas A y B solo dependen del 
						B <= '0';   --estado actual por ser fsm de Moore.
						if (H='0') then 
							qt <= E1; --tanque vac�o.
						else 
							qt <= E0; --tanque lleno.
						end if;
					when E1 =>	--tanque vac�o despu�s de estar lleno.
						A <= '1';	--se prende bomba A.
						B <= '0';	--se mantiene apagada bomba B.
						if (H='1') then 
							qt <= E2; --tanque lleno.
						else
							qt <= E1; --tanque vac�o
						end if;
					when E2 => --tanque lleno desp�es de utilizar A.
						A <= '0'; --se apaga bamba A.
						B <= '0'; --se mantiene apagada bomba B.
						if (H='0') then
							qt <= E3; --tanque vac�o.
						else 
							qt <= E2; --tanque lleno.
						end if;
					when E3 =>	--tanque vac�o despu�s de haberse llenado la �ltima ocasi�n con A.
						A <= '0';	--se mantiene apagada bomba A.
						B <= '1';	--se prende bomba B.
						if (H='1') then 
							qt <= E0; --tanque lleno.
						else
							qt <= E3; --tanque vac�o
						end if;
				end case;
			end if;
	end process;

end Behavioral;

