library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_sel is
	 Generic ( LONGITUD_PROTA : integer := 32 );
    Port ( FILA : in  STD_LOGIC_VECTOR (9 downto 0);
           COLUMNA : in  STD_LOGIC_VECTOR (9 downto 0);
           VISIBLE : in  STD_LOGIC;
			  PROTA_FILA : in INTEGER;
			  PROTA_COLUM : in INTEGER;
			  NIVEL : in INTEGER;
           RED : out  STD_LOGIC_VECTOR (4 downto 0);
           BLUE : out  STD_LOGIC_VECTOR (4 downto 0);
           GREEN : out  STD_LOGIC_VECTOR (5 downto 0));
end vga_sel;

architecture Behavioral of vga_sel is

	signal fila_s : integer range 0 to 63 := 0;
	signal columna_s : integer range 0 to 63 := 0;
	signal fila_p : integer range 0 to 32 := 0;
	signal columna_p : integer range 0 to 32 := 0;
	signal color,color0,color1 : integer range 0 to 16 := 0;

	--COnjunto de memorias con las pantallas y los niveles del juego
	COMPONENT mem_fondo
	PORT(
		NIVEL : IN integer;
		FILA : IN integer;
		COLUMNA : IN integer;          
		COLORES : OUT integer
		);
	END COMPONENT;

	--Memoria con los colores que definen al protagonista
	COMPONENT mem_prota
	PORT(
		FILA : IN integer;
		COLUMNA : IN integer;          
		COLOR : OUT integer
		);
	END COMPONENT;

begin
	
	--Se desprecian los ultimos 5 bits porque los bloques de mem_fondo son de 32 x 32 pixeles
	fila_s <= to_integer(unsigned(FILA(9 downto 5)));
	columna_s <= to_integer(unsigned(COLUMNA(9 downto 5)));
	
	--Se toman los ultimos 5 bits por si el protagonista esta en posicion para imprimirlo
	fila_p <= to_integer(unsigned(FILA(4 downto 0)));
	columna_p <= to_integer(unsigned(COLUMNA(4 downto 0)));
	
	--Se lee de la memoria
	Inst_mem_fondo: mem_fondo PORT MAP(
		NIVEL => NIVEL,
		FILA => fila_s,
		COLUMNA => columna_s,
		COLORES => color0
	);
	
	--Se lee de la memoria
	Inst_mem_prota: mem_prota PORT MAP(
		FILA => fila_p,
		COLUMNA => columna_p,
		COLOR => color1
	);
	
	--Proceso que controla que color se imprime en un pixel ubicado en cierta FILA y COLUMNA
	process(FILA,COLUMNA,PROTA_FILA,PROTA_COLUM,color0,color1)
	begin
	
		--Si en esa posicion esta el protagonista toma el color de este, si es 0 se debe imprimir el color del fondo.
		--Si no esta el protagonista en ese pixel solo se imprime el color de fondo.
		if ( (to_integer(unsigned(FILA)) >= PROTA_FILA ) and (to_integer(unsigned(FILA)) < PROTA_FILA + LONGITUD_PROTA) ) then
			if ( (to_integer(unsigned(COLUMNA)) >= PROTA_COLUM ) and (to_integer(unsigned(COLUMNA)) < PROTA_COLUM + LONGITUD_PROTA) ) then
				if (color1 = 0) then
					color <= color0;
				else
					color <= color1;
				end if;
			else
				color <= color0;
			end if;
		else
			color <= color0;
		end if;
	end process;
	
	--Asigna los colores dependiendo del contenido de lamemoria y si es de la zona visible
	process(color,VISIBLE)
	begin
		if (VISIBLE = '1') then
			if (color = 1) then --negro
				RED <= "00000";
				BLUE <= "00000";
				GREEN <= "000000";
			elsif (color = 2) then --rojo
				RED <= "11111";
				BLUE <= "00000";
				GREEN <= "000000";
			elsif (color = 3) then --azul
				RED <= "00000";
				BLUE <= "11111";
				GREEN <= "000000";
			elsif (color = 4) then --verde
				RED <= "00000";
				BLUE <= "00000";
				GREEN <= "111111";
			elsif (color = 5) then --rosa
				RED <= "11111";
				BLUE <= "11111";
				GREEN <= "011000";
			elsif (color = 6) then --amarillo
				RED <= "11111";
				BLUE <= "00000";
				GREEN <= "111111";
			elsif (color = 7) then --azul oscuro
				RED <= "00000";
				BLUE <= "00111";
				GREEN <= "001111";
			elsif (color = 8) then -- gris
				RED <= "10000";
				BLUE <= "10000";
				GREEN <= "100000";
			elsif (color = 9) then --verde oscuro
				RED <= "00000";
				BLUE <= "00000";
				GREEN <= "001000";
			elsif (color = 10) then --pistache
				RED <= "10001";
				BLUE <= "10001";
				GREEN <= "111111";
			elsif (color = 11) then --naranja
				RED <= "11111";
				BLUE <= "00001";
				GREEN <= "001111";
			elsif (color = 12) then --morado
				RED <= "00111";
				BLUE <= "00111";
				GREEN <= "000000";
			elsif (color = 13) then --azul cielo
				RED <= "00000";
				BLUE <= "11000";
				GREEN <= "100000";
			elsif (color = 14) then --cafe
				RED <= "00111";
				BLUE <= "00000";
				GREEN <= "000111";
			else --blanco
				RED <= "11111";
				BLUE <= "11111";
				GREEN <= "111111";
			end if;
		else
			RED <= "00000";
			BLUE <= "00000";
			GREEN <= "000000";
		end if;
	end process;

end Behavioral;

