--Práctica 3: Máquinas de estados finitos(FSM), máquina de Mealy.
--Equipo:
--Aceves Núñez Jonathan Gerardo
--Contreras Jiménez Sergio Brian
--Mora Magaña José David Divad
--Orozco Montes Zaid Andrés

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mealy is
    Port ( CLK : in  STD_LOGIC;
           H : in  STD_LOGIC;
			  RST : in STD_LOGIC;
           A : out  STD_LOGIC;
           B : out  STD_LOGIC);
end mealy;

architecture Behavioral of mealy is

	type estados is (E0,E1,E2,E3); --descripción de máquina de estados.
	signal edo_act,edo_sig : estados; --señal para estado siguiente de tabla de transiciones.

begin

	process(CLK,RST) --proceso para reset y cambio de estados.
	begin
		if (RST = '1') then
			edo_act <= E0;
		elsif (rising_edge(CLK)) then
			edo_act <= edo_sig;
		end if;
	end process;
	
	process(edo_act,H) --proceso para decidir estado siguiente.
	begin
		case edo_act is
			when E0 => --tanque lleno en inicio, bombas apagadas.
				if (H = '0') then --si el tanque está vacío se cambia de estado.
					A <= '0'; --se puede observar que las salidas A y B dependen de la entrada H
					B <= '0'; --y del estado actual, a diferencia de la fsm de Moore donde solo
					edo_sig <= E1; --se tomaba en cuenta el estado actual.
				else --tanque está lleno se mantiene estado.
					A <= '0';
					B <= '0';
					edo_sig <= E0;
				end if;
			when E1 => --tanque vacío pero previamente lleno, se prende A.
				if (H = '0') then --si el tanque está vacío se mantiene estado.
					A <= '1'; 
					B <= '0';
					edo_sig <= E1;
				else --si el tanque está lleno se cambia de estado.
					A <= '1';
					B <= '0';
					edo_sig <= E2;
				end if;
			when E2 => --tanque lleno usando A, se apaga A.
				if (H = '0') then --tanque vacío, se cambia de estado.
					A <= '0';
					B <= '0';
					edo_sig <= E3;
				else --tanque lleno, se mantiene estado.
					A <= '0';
					B <= '0';
					edo_sig <= E2;
				end if;
			when others => --tanque vacío despúes de haber sido llenado la vez anterior usando
						   --se prende B.
				if (H = '0') then --tanque vacío, se mantiene estado.
					A <= '0';
					B <= '1';
					edo_sig <= E3;
				else --tanque lleno, se cambia de estado.
					A <= '0';
					B <= '1';
					edo_sig <= E0;
				end if;	
			end case;
		end process;

end Behavioral;

