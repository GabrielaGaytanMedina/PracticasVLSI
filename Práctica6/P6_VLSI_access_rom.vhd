library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity access_rom is
    Port ( CLK : in STD_LOGIC;
			  POS_DISP : out STD_LOGIC_VECTOR (7 downto 0);
           DISP : out  STD_LOGIC_VECTOR (6 downto 0));
end access_rom;

architecture Behavioral of access_rom is

	--contadores que estan asociados a cada display, estos estan desfasados en una unidad respecto al anterior
	signal tem1 : std_logic_vector (3 downto 0) := X"0";
	signal tem2 : std_logic_vector (3 downto 0) := X"1";
	signal tem3 : std_logic_vector (3 downto 0) := X"2";
	signal tem4 : std_logic_vector (3 downto 0) := X"3";
	
	--pos es la posicion de la memoria que se va a leer
	signal pos : std_logic_vector (3 downto 0) := X"0";
	
	--conta y divi se usan para el divisor de frecuencia con el que se hace el conteo de las señales tem
	signal conta : integer range 0 to 64000000 := 0;
	signal divi : std_logic := '0';
	
	--conta2 y divi2 se usan para el divisor de frecuencia con el que se enciende un display de los 8 disponibles
	signal conta2 : integer range 0 to 2000 := 0;
	signal divi2 : std_logic := '0';
	
	--sel se usa para seleccionar que display se enciende
	signal sel : integer range 0 to 4 := 0;

	--con esta parte se llama a miROM
	COMPONENT miROM
	PORT(
		addr : IN std_logic_vector(3 downto 0);          
		data : OUT std_logic_vector(6 downto 0)
		);
	END COMPONENT;

begin

--proceso que depende del reloj maestro para los divisores de frecuencia
process(CLK)
begin
	if rising_edge(CLK) then
		--aqui se hace el primer divisor de frecuencia
		if(conta = 31999999) then
			conta <= 0;
			divi <= not divi;
		else 
			conta <= conta + 1;
		end if;
		
		--aqui se hace el segundo divisor de frecuencia
		if(conta2 = 1999) then
			conta2 <= 0;
			divi2 <= not(divi2);
		else
			conta2 <= conta2 + 1;
		end if;
	end if;
end process;
		
--proceso para el cambio de display
process(divi2)
begin
	if rising_edge(divi2) then
		--dependiendo del valor de 'sel' se activa un display y se 
		--mostrara en este el valor que este en su contador asociado 
		case sel is
			when 0 =>
				POS_DISP <= "11101111";
				pos <= tem1;
				sel <= 1;
			when 1 =>
				POS_DISP <= "11011111";
				pos <= tem2;
				sel <= 2;
			when 2 =>
				POS_DISP <= "10111111";
				pos <= tem3;
				sel <= 3;
			when others =>
				POS_DISP <= "01111111";
				pos <= tem4;
				sel <= 0;
		end case;
		
	end if;
end process;

--proceso de aumento de los contadores, donde cada uno es independiente del resto
process(divi)
begin
	if rising_edge(divi) then
		--para el primer contador 'tem1'
		if( tem1 = "1111" ) then
			tem1 <= X"0";
		else
			tem1 <= tem1 + 1;
		end if;
		
		--para el segundo contador 'tem2'
		if( tem2 = "1111" ) then
			tem2 <= X"0";
		else
			tem2 <= tem2 + 1;
		end if;
		
		--para el tercer contador 'tem3'
		if( tem3 = "1111" ) then
			tem3 <= X"0";
		else
			tem3 <= tem3 + 1;
		end if;
		
		--para el tercer contador 'tem4'
		if( tem4 = "1111" ) then
			tem4 <= X"0";
		else
			tem4 <= tem4 + 1;
		end if;
	end if;
end process;

	--se llama a miROM usando a pos que tiene el valor del contador asociado al 
	--display actual y manda a la salida lo que hay en la memoria
	Inst_miROM: miROM PORT MAP(
		addr => pos,
		data => DISP
	);

end Behavioral;

