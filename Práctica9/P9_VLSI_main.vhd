library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity main is
    Port ( CLK : in  STD_LOGIC;
			  RX : in STD_LOGIC;
			  TX : out STD_LOGIC;
			  LED : out STD_LOGIC_VECTOR(7 downto 0);
			  STW : in STD_LOGIC_VECTOR(7 downto 0);
			  ENV_PB : in STD_LOGIC);
end main;

architecture Behavioral of main is

	--agregando el componente necesario para la comunicacion UART
	component RS232 is 
	generic (FPGA_CLK: integer := 50000000;
				BAUD_RS232: integer := 9600);
	port	(	CLK : 		in std_logic ;			--Reloj de FPGA
				RX :			in std_logic ;			--Pin de recepción de RS232
				TX_INI :		in std_logic ;			--Debe ponerse a '1' para inciar transmisión
				TX_FIN :		out std_logic ;		--Se pone '1' cuando termina la transmisión
				TX :			out std_logic ;		--Pin de transmisión de RS232
				RX_IN :		out std_logic ;		--Se pone a '1' cuando se ha recibido un Byte. Solo dura un 
															--Ciclo de reloj
				DATAIN :		in std_logic_vector(7 downto 0); --Puerto de datos de entrada para transmisión
				DOUT :		out std_logic_vector(7 downto 0) --Puerto de datos de salida para recepción
			);
	end component RS232;
	
	--señales utilizadas para la comunicacion UART
	signal tx_ini_s,tx_fin_s,rx_in_s : std_logic := '0';
	signal datain_s,dout_s,midato_s : std_logic_vector(7 downto 0) := X"00";

begin
	--Los datos de entrada (los switches) se asignan en data_in_s
	datain_s <= STW;
	
	--mandamos las entradas y señales correscpondientes al componente que hara todo el trabajo de la comonicacion
	Inst_RS232: RS232 GENERIC MAP(
		FPGA_CLK => 50000000,
		BAUD_RS232 => 9600)
	PORT MAP(
		CLK => CLK,
		RX => RX,
		TX_INI => tx_ini_s,
		TX_FIN => tx_fin_s,
		TX => TX,
		RX_IN => rx_in_s,
		DATAIN => datain_s,
		DOUT => dout_s
	);

	process(CLK,tx_fin_s,rx_in_s,ENV_PB)
	begin
		--Parte de la transmicion
		if(tx_fin_s = '1') then --Si termino de transmitir manda la señal que inicia la transmicion a 0
			tx_ini_s <= '0';
		elsif (ENV_PB = '1') then --Si el boton de enviar (ENV_PB) esta en 1 manda la señal tx_ini_s a 1 para iniciar la transmicion
			tx_ini_s <='1';
		end if;
		
		--Parte de la recepcion
		if(rx_in_s = '1') then --Si ya termino de recibir asigna el byte a midato_s
			midato_s <= dout_s;
			--Las siguientes instrucciones tienen la finalidad de que unicamente se muestre el codigo binario de los numeros
			--que se envien, al principio intentamos restar X"30" (codigo ascii hexadecimal del 0) pero no funciono como 
			--esperabamos por lo que optamos por mandar directamente los bits mas significativos a 0 y el resto tomarlo del
			--byte recibido
			LED(7 downto 4) <= "0000";
			LED(3 downto 0) <= midato_s(3 downto 0); 
		end if;
	end process;

end Behavioral;

