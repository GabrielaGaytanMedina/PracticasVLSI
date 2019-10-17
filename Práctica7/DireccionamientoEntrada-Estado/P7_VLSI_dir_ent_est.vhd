library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dir_ent_est is
    Port ( A : in  STD_LOGIC;
           B : in  STD_LOGIC;
           C : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           S : out  STD_LOGIC_VECTOR (5 downto 0);
			  DISP : out STD_LOGIC_VECTOR (6 downto 0));
end dir_ent_est;

architecture Behavioral of dir_ent_est is

	--señales que representan los estados presente y siguiente.
	signal est_pres,est_sig : std_logic_vector(2 downto 0) := "000";
	
	--señal que guarda lo que hay en memoria
	signal memo : std_logic_vector (13 downto 0);
	
	--señal para seleccionar la liga verdadera o falsa
	signal liga : std_logic;
	
	signal conta : INTEGER range 0 to 64000000 := 0;--se usa para el divisor
	signal divi : STD_LOGIC := '0';--el reloj ya dividido
	
	COMPONENT memROM
	PORT(
		addr : IN std_logic_vector(2 downto 0);          
		data : OUT std_logic_vector(13 downto 0)
		);
	END COMPONENT;

begin

--divisor de frecuencia
process(CLK)
begin
	if rising_edge(CLK) then
		if(conta = 24999999) then
			conta <= 0;
			divi <= not divi;
		else 
			conta <= conta + 1;
		end if;
	end if;
end process;

--proceso de cambio de estado
process(divi,RST)
begin
	if(RST = '1') then
		est_pres <= "000";
	elsif rising_edge(divi) then
		est_pres <= est_sig;
	end if;
end process;

	Inst_memROM: memROM PORT MAP(
		addr => est_pres, --se lee de la memoria con el estado presente
		data => memo --en memo se guarda lo que hay en la memoria
	);
	
--multiplexor de las entradas
process(memo,A,B,C)
begin
	--preguntamos por las pruebas
	if(memo(13) = '0' and memo(12) = '0') then
		--caso Aux
		liga <= '1';
	elsif (memo(13) = '0' and memo(12) = '1') then
		--caso A
		liga <= A;
	elsif (memo(13) = '1' and memo(12) = '0') then
		--caso B
		liga <= B;
	else
		--caso C
		liga <= C;
	end if;
end process;

--multiplexor de los estados
process(liga,memo)
begin
	if (liga = '0') then
		est_sig (2) <= memo(11);
		est_sig (1) <= memo(10);
		est_sig (0) <= memo(9);
	else
		est_sig (2) <= memo(8);
		est_sig (1) <= memo(7);
		est_sig (0) <= memo(6);
	end if;
end process;

--asignacion de las salidas;
S(5) <= memo(5);
S(4) <= memo(4);
S(3) <= memo(3);
S(2) <= memo(2);
S(1) <= memo(1);
S(0) <= memo(0);

--como adicional en el display de 7 segmentos se vera el estado presente
process (est_pres)
begin
	case est_pres is
	when "000" =>
		DISP <= "1000000";-- 0
	when "001" =>
		DISP <= "1111001";-- 1
	when "010" =>
		DISP <= "0100100";-- 2
	when "011" =>
		DISP <= "0110000";-- 3
	when "100" =>
		DISP <= "0011001";-- 4 
	when "101" =>
		DISP <= "0010010";-- 5
	when "110" =>
		DISP <= "0000010";-- 6
	when others =>
		DISP <= "1111000";-- 7 
	end case;
end process;
end Behavioral;

