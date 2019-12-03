library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity disp_7s is
    Port ( VIDA : in  integer;
			  CLK : in STD_LOGIC;
           SEVEN_SEG : out  STD_LOGIC_VECTOR (6 downto 0);
           POS : out  STD_LOGIC_VECTOR (5 downto 0));
end disp_7s;

architecture Behavioral of disp_7s is
		
		--señales para el divisor de frecuencia
	signal divi : std_logic := '0';
	signal conta : integer range 0 to 10000 := 0;
	
	type estados is (q0,q1,q2,q3,q4,q5); --estados del programa
	signal edo_pres : estados := q0; --estado presente
	signal more_sig,less_sig : std_logic_vector (6 downto 0) := "0000000"; --señales con la representacion de las cifras
																								  --mas y menos significativos de vida

begin

	--proceso que asigna las cifras a las señales
	process(VIDA)
	begin
		if (VIDA = 0) then
			more_sig <= "1000000";
			less_sig <= "1000000";
		elsif (VIDA = 1) then
			more_sig <= "1000000";
			less_sig <= "1111001";
		elsif (VIDA = 2) then
			more_sig <= "1000000";
			less_sig <= "0100100";
		elsif (VIDA = 3) then
			more_sig <= "1000000";
			less_sig <= "0110000";
		elsif (VIDA = 4) then
			more_sig <= "1000000";
			less_sig <= "0011001";
		elsif (VIDA = 5) then
			more_sig <= "1000000";
			less_sig <= "0010010";
		elsif (VIDA = 6) then
			more_sig <= "1000000";
			less_sig <= "0000010";
		elsif (VIDA = 7) then
			more_sig <= "1000000";
			less_sig <= "1111000";
		elsif (VIDA = 8) then
			more_sig <= "1000000";
			less_sig <= "0000000";
		elsif (VIDA = 9) then
			more_sig <= "1000000";
			less_sig <= "0011000";
		elsif (VIDA = 10) then
			more_sig <= "1111001";
			less_sig <= "1000000";
		elsif (VIDA = 11) then
			more_sig <= "1111001";
			less_sig <= "1111001";
		elsif (VIDA = 12) then
			more_sig <= "1111001";
			less_sig <= "0100100";
		elsif (VIDA = 13) then
			more_sig <= "1111001";
			less_sig <= "0110000";
		elsif (VIDA = 14) then
			more_sig <= "1111001";
			less_sig <= "0011001";
		else
			more_sig <= "1111001";
			less_sig <= "0010010";
		end if;
	end process;
			
			
	--divisor de frecuencia
	process(CLK)
	begin
		if (rising_edge(CLK)) then
			if (conta = 10000) then
				conta <= 0;
				divi <= not(divi);
			else
				conta <= conta + 1;
			end if;
		end if;
	end process;
	
	--maquina de estados, se mueve secuencialmente de q0 a q5 encendiendo solo el display indicado en pos,
	--dependiendo de este asignara al displey la cifra mas significativa, la menos significativa o apagara los
	--7 segmentos.
	process(divi)
	begin
		if(rising_edge(divi)) then
			if (edo_pres = q0) then
				edo_pres <= q1;
				POS <= not "000001";
				SEVEN_SEG <= less_sig;
			elsif (edo_pres = q1) then
				edo_pres <= q2;
				POS <= not "000010";
				SEVEN_SEG <= more_sig;
			elsif (edo_pres = q2) then
				edo_pres <= q3;
				POS <= not "000100";
				SEVEN_SEG <= "1111111";
			elsif (edo_pres = q3) then
				edo_pres <= q4;
				POS <= not "001000";
				SEVEN_SEG <= "1111111";
			elsif (edo_pres = q4) then
				edo_pres <= q5;
				POS <= not "010000";
				SEVEN_SEG <= "1111111";
			else
				edo_pres <= q0;
				POS <=  not"100000";
				SEVEN_SEG <= "1111111";
			end if;
		end if;
	end process;
	
end Behavioral;

