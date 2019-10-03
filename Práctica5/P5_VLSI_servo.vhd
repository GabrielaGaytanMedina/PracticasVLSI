library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity servo is
    Port ( CLK : in  STD_LOGIC;
			  RST : in STD_LOGIC;
           ENT : in  STD_LOGIC_VECTOR (3 downto 0);
			  LED_RST : out STD_LOGIC;
			  DIG : out STD_LOGIC_VECTOR (3 downto 0);
           SAL : out  STD_LOGIC);
end servo;

architecture Behavioral of servo is

signal conta: integer range 0 to 1000000 := 0;
signal lim : integer range 0 to 150000 := 0;
signal pulso_pwm : std_logic;

begin

--Salida que muestra en unos leds la entrada
DIG <= ENT;
LED_RST <= RST;

--proceso para saber el limite (lim) para el pulso pwm
process(RST,ENT)
begin
	if (RST = '1') then
		lim <= 24999; --para la posicion de 0°
	else case ENT is
		when "0000" =>
			lim <= 24999; --para 0° aprox 0.5[ms]
		when "0001" =>
			lim <= 31428; 
		when "0010" =>
			lim <= 37856; 
		when "0011" =>
			lim <= 44284; 
		when "0100" =>
			lim <= 50712; 
		when "0101" =>
			lim <= 57148; 
		when "0110" =>
			lim <= 63568; 
		when "0111" =>
			lim <= 69999; --para 90° aprox 1.4[ms]
		when "1000" =>
			lim <= 76749; 
		when "1001" =>
			lim <= 83499; 
		when "1010" =>
			lim <= 90249; 
		when "1011" =>
			lim <= 96999; 
		when "1100" =>
			lim <= 103749; 
		when "1101" =>
			lim <= 110499; 
		when "1110" =>
			lim <= 117249; 
		when others =>
			lim <= 123999; --para 180° aprox 2.48[ms]
	end case;
	end if;
end process;

--proceso que genera el pulso pwm
process(CLK,lim)
begin
	if (rising_edge(CLK)) then
		--si ya llego al limite deja en 0 la señal y reinicia conta
		--el limite de conta es para dividirlo a una frecuencia de 50[Hz] que es con lo que trabaja el servo
		if (conta = 999999) then
			pulso_pwm <= '0';
			conta <= 0;
		--si conta es mayor a conta deja en 0 la señal y aumenta a conta
		elsif (conta > lim) then
			pulso_pwm <= '0';
			conta <= conta + 1;
		--si conta es menor o igual a lim deja la señal en 1 y aumenta conta
		else
			pulso_pwm <= '1';
			conta <= conta +1;
		end if;
	end if;
end process;

--Se le asigna a la salida el pulso pwm
SAL <= pulso_pwm;

end Behavioral;

