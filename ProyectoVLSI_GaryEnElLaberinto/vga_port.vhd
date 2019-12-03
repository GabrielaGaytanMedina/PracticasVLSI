library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity vga_port is
	 Generic ( H_PIXEL : integer := 1024;
				  H_PORCHE_DELANTERO : integer := 8;
				  H_PORCHE_TRASERO : integer := 176;
				  SINCRO_H : integer := 56;
				  V_PIXEL : integer := 768;
				  V_PORCHE_DELANTERO : integer := 0;
				  V_PORCHE_TRASERO : integer := 8;
				  SINCRO_V : integer := 41);
    Port ( CLK : in  STD_LOGIC;
           H_SINC : out  STD_LOGIC;
           V_SINC : out  STD_LOGIC;
			  VISIBLE : out STD_LOGIC;
           FILA : out  STD_LOGIC_VECTOR (9 DOWNTO 0);
           COLUMNA : out  STD_LOGIC_VECTOR (9 DOWNTO 0));
end vga_port;

architecture Behavioral of vga_port is

	signal divi : std_logic := '0';
	signal h_counter : integer range 0 to 1264 := 0;
	signal v_counter : integer range 0 to 817 := 0;
	signal h_visible : std_logic := '0';
	signal v_visible : std_logic := '0';
	signal new_line : std_logic := '0';

begin

	--proceso de conteo
	process(CLK,h_counter,v_counter)
	begin
		--contador horizontal
		if(rising_edge(CLK)) then
			if (h_counter < H_PIXEL) then --Si es la zona visible
				h_counter <= h_counter + 1;
				h_visible <= '1';
				H_SINC <= '1';
				new_line <= '0';
			elsif (h_counter < H_PIXEL + H_PORCHE_DELANTERO) then --Si esta en el porche delantero
				h_counter <= h_counter + 1;
				h_visible <= '0';
				H_SINC <= '1';
				new_line <= '0';
			elsif (h_counter < H_PIXEL + H_PORCHE_DELANTERO + SINCRO_H) then --Si esta en la zona de sincronizacion
				h_counter <= h_counter + 1;
				h_visible <= '0';
				H_SINC <= '0';
				new_line <= '0';
			elsif (h_counter < H_PIXEL + H_PORCHE_DELANTERO + SINCRO_H + H_PORCHE_TRASERO - 1) then --Si esta en el porche trasero
				h_counter <= h_counter + 1;
				h_visible <= '0';
				H_SINC <= '1';
				new_line <= '0';
			else --Cuando esta en el ultimo pixel, el 1023
				h_counter <= 0;
				h_visible <= '0';
				H_SINC <= '1';
				new_line <= '1';
			end if;
			
			if (rising_edge(new_line)) then
				if (v_counter < V_PIXEL) then --Si es la zona visible
					v_counter <= v_counter + 1;
					v_visible <= '1';
					V_SINC <= '1';
				elsif (v_counter < V_PIXEL + V_PORCHE_DELANTERO) then --Si esta en el porche delantero
					v_counter <= v_counter + 1;
					v_visible <= '0';
					V_SINC <= '1';
				elsif (v_counter < V_PIXEL + V_PORCHE_DELANTERO + SINCRO_V) then --Si esta en la zona de sincronizacion
					v_counter <= v_counter + 1;
					v_visible <= '0';
					V_SINC <= '0';
				elsif (v_counter < V_PIXEL + V_PORCHE_DELANTERO + SINCRO_V + V_PORCHE_TRASERO - 1) then --Si esta en el porche trasero
					v_counter <= v_counter + 1;
					v_visible <= '0';
					V_SINC <= '1';
				else --Cuando esta en el ultimo pixel, el 767
					v_counter <= 0;
					v_visible <= '0';
					V_SINC <= '1';
				end if;
			end if;
			
			--Si se encuentra en un area visible tanto horizontalmente como verticalmente se activara o no la salida VISIBLE
			VISIBLE <= v_visible and h_visible;
			
			--Se convierte la fila y la columna a un vector para la salida
			FILA <= std_logic_vector(to_unsigned(v_counter,FILA'length));
			COLUMNA <= std_logic_vector(to_unsigned(h_counter,COLUMNA'length));
		end if;
	end process;

	

end Behavioral;

