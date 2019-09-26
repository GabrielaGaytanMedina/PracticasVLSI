
--Práctica 4: Cartas ASM.
--Equipo:
--Aceves Núñez Jonathan Gerardo
--Contreras Jiménez Sergio Brian
--Mora Magaña José David Divad
--Orozco Montes Zaid Andrés

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity asm is
    Port ( Si : in  STD_LOGIC;
           Sd : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           ADELANTE : out  STD_LOGIC;
           ATRAS : out  STD_LOGIC;
           GIRO_DER : out  STD_LOGIC;
           GIRO_IZQ : out  STD_LOGIC;
			  POS_LED : out STD_LOGIC_VECTOR (7 downto 0);
			  LED_IZQ : out STD_LOGIC;
			  LED_DER : out STD_LOGIC;
           LEDS : out  STD_LOGIC_VECTOR (6 downto 0));
end asm;

architecture Behavioral of asm is

	signal conta : INTEGER range 0 to 64000000 := 0;--se usa para el divisor
	signal divi : STD_LOGIC := '0';--el reloj ya dividido

	type estados is (Q0,Q1,Q2,Q3,Q4,Q5,Q6,Q7,Q8,Q9,QA,QB);
	signal edo_pres,edo_sig : estados := Q0;

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

--Proceso del cambio de estados.
process(RST,divi)
begin
	--Si se presiona el reset se regresa al estado Q0
	if(RST = '1') then 
		edo_pres <= Q0;
	elsif (rising_edge(divi)) then
		edo_pres <= edo_sig;
	end if;
end process;

--Salidas de apoyo para comprobar el valor de las entradas Si y Sd
LED_IZQ <= Si;
LED_DER <= Sd;

--Proceso de asignacion de estados
process(edo_pres,Si,Sd)
begin
	case edo_pres is
		--Solo en Q0 se pregunta por las entradas, por eso en los demas casos no hay if's y el siguiente estado ya esta definido
		when Q0 =>
			ADELANTE <= '0';
			ATRAS <= '0';
			GIRO_DER <= '0';
			GIRO_IZQ <= '0';
			--Salida para mostrar '0'
			LEDS <= "1000000";
			if(Si = '0' and Sd = '0') then
				--Salida condicional
				ADELANTE <= '1';
				edo_sig <= Q0;
			elsif (Si = '0' and Sd = '1') then
				edo_sig <= Q1;
			elsif (Si = '1' and Sd = '0') then 
				edo_sig <= Q3;
			else
				edo_sig <= Q5;
			end if;
		when Q1 =>
			ADELANTE <= '0';
			ATRAS <= '1';
			GIRO_DER <= '0';
			GIRO_IZQ <= '0';
			--Salida para mostrar '1'
			LEDS <= "1111001";
			edo_sig <= Q2;
		when Q2 =>
			ADELANTE <= '0';
			ATRAS <= '0';
			GIRO_DER <= '0';
			GIRO_IZQ <= '1';
			--Salida para mostrar '2'
			LEDS <= "0100100";
			edo_sig <= Q0;
		when Q3 =>
			ADELANTE <= '0';
			ATRAS <= '1';
			GIRO_DER <= '0';
			GIRO_IZQ <= '0';
			--Salida para mostrar '3'
			LEDS <= "0110000";
			edo_sig <= Q4;
		when Q4 =>
			ADELANTE <= '0';
			ATRAS <= '0';
			GIRO_DER <= '1';
			GIRO_IZQ <= '0';
			--Salida para mostrar '4'
			LEDS <= "0011001";
			edo_sig <= Q0;
		when Q5 =>
			ADELANTE <= '0';
			ATRAS <= '1';
			GIRO_DER <= '0';
			GIRO_IZQ <= '0';
			--Salida para mostrar '5'
			LEDS <= "0010010";
			edo_sig <= Q6;
		when Q6 =>
			ADELANTE <= '0';
			ATRAS <= '0';
			GIRO_DER <= '0';
			GIRO_IZQ <= '1';
			--Salida para mostrar '6'
			LEDS <= "0000010";
			edo_sig <= Q7;
		when Q7 =>
			ADELANTE <= '0';
			ATRAS <= '0';
			GIRO_DER <= '0';
			GIRO_IZQ <= '1';
			--Salida para mostrar '7'
			LEDS <= "0111000";
			edo_sig <= Q8;
		when Q8 =>
			ADELANTE <= '1';
			ATRAS <= '0';
			GIRO_DER <= '0';
			GIRO_IZQ <= '0';
			--Salida para mostrar '8'
			LEDS <= "0000000";
			edo_sig <= Q9;
		when Q9 =>
			ADELANTE <= '1';
			ATRAS <= '0';
			GIRO_DER <= '0';
			GIRO_IZQ <= '0';
			--Salida para mostrar '9'
			LEDS <= "0011000";
			edo_sig <= QA;
		when QA =>
			ADELANTE <= '0';
			ATRAS <= '0';
			GIRO_DER <= '1';
			GIRO_IZQ <= '0';
			--Salida para mostrar 'A'
			LEDS <= "0001000";
			edo_sig <= QB;
		when others =>
			ADELANTE <= '0';
			ATRAS <= '0';
			GIRO_DER <= '1';
			GIRO_IZQ <= '0';
			--Salida para mostrar 'b'
			LEDS <= "0000011";
			edo_sig <= Q0;
	end case;
end process;

--Salida para encender unicamente un display de la fpga
POS_LED <= "11101111";

end Behavioral;

