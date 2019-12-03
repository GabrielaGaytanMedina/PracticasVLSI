library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity main is
	 --Constantes del juego
	 Generic ( D_VEN : integer := 3; --Daño por veneno
				  D_MOHO : integer := 1; --Daño por moho
				  D_FUEGO : integer := 5; --Daño por fuego
				  D_LAVA : integer := 10; --Daño por lava
				  NUM_NIV : integer := 3; --Numero de niveles
				  NIV_INI : integer := 0; --Nivel/Estado de la pantalla inicial
				  NIV_GO : integer := 5; --Nivel/Estado de la pantalla de juego terminado
				  NIV_WIN : integer := 4; --Nivel/Estado de la pantalla de victoria
				  VIDA_FULL : integer := 15; --Vida maxima
				  LONG_PIXI : integer := 32); --Tamaño de los cuadros (32 pixeles x 32 pixeles)
    
	 --Entradas y salidas
	 Port ( CLK : in  STD_LOGIC; --Reloj maestro
							   --Botones de la FPGA
			  B_UP : in STD_LOGIC; --Boton de movimiento hacia arriba
			  B_DOWN : in STD_LOGIC; --Boton de moviemiento hacia abajo
			  B_LEFT : in STD_LOGIC; --Boton de movimiento hacia la izquieda
			  B_RIGHT : in STD_LOGIC; --Boton de movimiento hacia la derecha
			  RST : in STD_LOGIC; --Boton de reset
								--Todos los botones funcionan con logica negada
								
								--Salidas del puerto VGA de la FPGA
           RED : out  STD_LOGIC_VECTOR (4 downto 0); --Color rojo
           GREEN : out  STD_LOGIC_VECTOR (5 downto 0); --Color verde
           BLUE : out  STD_LOGIC_VECTOR (4 downto 0); --Color azul
           H_SINC : out  STD_LOGIC; --Sinconizacion horizontal
           V_SINC : out  STD_LOGIC; --Sinconizacion vertical
				
							   --Salidas de los displays de 7 segmentos
			  DISP : out STD_LOGIC_VECTOR (6 downto 0); --Display de 7 segmentos
			  POS : out STD_LOGIC_VECTOR (5 downto 0); --Posicion de los 6 displays
			  
			  LEDS : out STD_LOGIC_VECTOR (3 downto 0) ); --Salida donde estan las vidas actuales del jugador
end main;

architecture Behavioral of main is

	--Memorias de los niveles y diferentes pantallas
	COMPONENT mem_fondo
	PORT(
		NIVEL : IN integer;
		FILA : IN integer;
		COLUMNA : IN integer;          
		COLORES : OUT integer
		);
	END COMPONENT;

	--Asigna a los displays de 7 segmentos el valor correspondiendo de acuerdo a la vida del jugador y 
	--la posicion del display actual
	COMPONENT disp_7s
	PORT(
		VIDA : IN integer;          
		CLK : IN std_logic;
		SEVEN_SEG : OUT std_logic_vector(6 downto 0);
		POS : OUT std_logic_vector(5 downto 0)
		);
	END COMPONENT;

	--Se encarga de recorrer la pantalla generando las señales de sincronizacion
	COMPONENT vga_port
	PORT(
		CLK : IN std_logic;          
		H_SINC : OUT std_logic;
		V_SINC : OUT std_logic;
		VISIBLE : OUT std_logic;
		FILA : OUT std_logic_vector(9 downto 0);
		COLUMNA : OUT std_logic_vector(9 downto 0)
		);
	END COMPONENT;

	--Selecciona el color dependiendo de la posicion actual en la pantalla, el Nivel/Estado actual
	--y de la posicion del protagonista (Gary)
	COMPONENT vga_sel
	GENERIC ( LONGITUD_PROTA : integer := LONG_PIXI );
	PORT(
		FILA : IN std_logic_vector(9 downto 0);
		COLUMNA : IN std_logic_vector(9 downto 0);
		VISIBLE : IN std_logic;    
		PROTA_FILA : in INTEGER;
		PROTA_COLUM : in INTEGER;  
		NIVEL : in INTEGER;
		RED : OUT std_logic_vector(4 downto 0);
		BLUE : OUT std_logic_vector(4 downto 0);
		GREEN : OUT std_logic_vector(5 downto 0)
		);
	END COMPONENT;

	--Obtiene los colores adyacentes a donde se encuentra el protagonista
	COMPONENT sig_color
	PORT(
		FILA : IN integer;
		COLUMNA : IN integer;
		NIVEL : IN integer;          
		COLOR_UP : OUT integer;
		COLOR_DW : OUT integer;
		COLOR_LF : OUT integer;
		COLOR_RG : OUT integer
		);
	END COMPONENT;

								--Señale puente entre vga_port y vga_sel
	signal visible : std_logic;
	signal fila,columna : std_logic_vector (9 downto 0) := "0000000000";
	
								--Posicion actual del protagonista
	signal prota_f : integer range 0 to 767:= 32; --Su fila
	signal prota_c : integer range 0 to 1023:= 32; --Su columna
	
								--Señales para el divisor de frecuencia
	signal divi : std_logic := '0';
	signal conta : integer range 0 to 12499999 := 0;
	
	signal color_up,color_dw,color_rg,color_lf : integer range 0 to 15 := 0; --Colores aledaños al protagonista
	
	signal vida : integer range 0 to 15 := VIDA_FULL; --Vida actual del jugador
	
	signal lifes : std_logic_vector (3 downto 0) := "1111"; --Vidas (lifes) actuales del jugador
	
	signal new_level : std_logic := '0'; --'0' si no hay que cambiar de nivel/estado
													 --'1' si hay que cambiar de nivel/estado
	
	signal new_mov : std_logic := '0'; --'0' si el jugador solto un boton y puede volver a moverse
												  --'1' si el jugador no ha soltado un boton y entonces no lo dejara moverse ni cambiar de pantalla

								--Constante con las posiciones iniciales del protagonista
								--Para las pantallas que no son niveles manda al protagonista a una zona no visible en la pantalla
	type coor is array (0 to 5,0 to 1) of integer;
	constant prota_ini : coor := (
		(32,32), 
		(64,96),
		(32,576),
		(64,96),
		(32,32),
		(32,32)
	);
	
	signal niv : integer range 0 to 5 := NIV_INI; --señal que indica en que nivel/estado se encuentra actualmente
	
begin

	Inst_disp_7s: disp_7s PORT MAP(
		VIDA => vida,
		CLK => CLK,
		SEVEN_SEG => DISP,
		POS => POS
	);


	Inst_vga_port: vga_port PORT MAP(
		CLK => CLK,
		H_SINC => H_SINC,
		V_SINC => V_SINC,
		VISIBLE => visible,
		FILA => fila,
		COLUMNA => columna
	);

	Inst_vga_sel: vga_sel PORT MAP(
		FILA => fila,
		COLUMNA => columna,
		VISIBLE => visible,  
		PROTA_FILA => prota_f,
		PROTA_COLUM => prota_c,
		NIVEL => niv,
		RED => RED,
		BLUE => BLUE,
		GREEN => GREEN
	);
	
	Inst_sig_color: sig_color PORT MAP(
		FILA => prota_f,
		COLUMNA => prota_c,
		NIVEL => niv,
		COLOR_UP => color_up,
		COLOR_DW => color_dw,
		COLOR_LF => color_lf,
		COLOR_RG => color_rg
	);

	--Divisor de frecuencia
	process(CLK)
	begin
		if (rising_edge(CLK)) then
			if (conta = 1249999) then
				conta <= 0;
				divi <= not(divi);
			else
				conta <= conta + 1;
			end if;
		end if;
	end process;
	
	--Proceso principal que controla todo el juego, en este los niveles se pueden considerar
	--los estados de una maquina de estados.
	process(divi,niv,B_UP,B_DOWN,B_LEFT,B_RIGHT,RST,new_mov,new_level)
	begin
		if (rising_edge(divi)) then
			--Si el resert esta activado asigna los parametros principales a las condiciones
			--de inicio.
			if (RST = '0') then
				niv <= NIV_INI;
				prota_f <= prota_ini(NIV_INI,0);
				prota_c <= prota_ini(NIV_INI,1);
				new_level <= '0';
				new_mov <= '0';
			else
			
				--Si se encuentra en un nivel jugable y no hay que cambiar de nivel entonces verificara
				--el estado de los botones de movimiento y la señal de movimiento, se pueden oprimir dos
				--botones al mismo tiempo, pero solo se movera hacia una direccion segun la siguiente 
				--presedencia de movimiento; arriba, abajo, izquierda y derecha respectivamente.
				if (niv>NIV_INI and niv <= NUM_NIV  and new_level = '0') then
					
					--En general el movieminto se comporta de la misma manera en todos los casos, primero se tiene
					--que presionar el boton de la direccion en la que se quiere mover, si ademas la señal de moviento
					--indica que se puede mover primero vefificara que se puede mover en esa direccion, si el color de
					--esa direccion es uno no accesible (negro, gris o cafe) no modificara su posicion ni su vida, pero
					--si es un bloque accesible vera si es le hace daño o no, si no le hace daño avanza y no modifica la
					--vida, si hace daño y tiene vida sufiente le resta el daño del bloque y avanza pero si no tiene vida
					--sufiente le resta una life al jugador si tiene suficientes, si no tiene lifes sufientes lo manda
					--al nivel de game over, por ultimo si llega al bloque de meta manda una señal de nuevo nivel (new_level <= 1)
					--para que la maquina de estados cambie de nivel
					
					if (B_UP = '0' and new_mov = '0') then
						new_mov <= '1';
						if (color_up = 1 or color_up = 8 or color_up = 14) then
							prota_f <= prota_f;
							prota_c <= prota_c;
						elsif (color_up = 7) then
							prota_f <= prota_f - LONG_PIXI;
							prota_c <= prota_c;
						elsif (color_up = 9) then
							if (vida > D_MOHO) then
								vida <= vida - D_MOHO;
								prota_f <= prota_f - LONG_PIXI;
								prota_c <= prota_c;
							else 
								if (lifes = "0000") then
									niv <= NIV_GO;
									new_level <= '0';
									prota_f <= prota_ini(NIV_GO,0);
									prota_c <= prota_ini(NIV_GO,1);
								else
									lifes <= lifes(2 downto 0) & '0';
									prota_f <= prota_ini(niv,0);
									prota_c <= prota_ini(niv,1);
									vida <= VIDA_FULL;
								end if;
							end if;
						elsif (color_up = 2) then
							if (vida > D_FUEGO) then
								vida <= vida - D_FUEGO;
								prota_f <= prota_f - LONG_PIXI;
								prota_c <= prota_c;
							else 
								if (lifes = "0000") then
									niv <= NIV_GO;
									new_level <= '0';
									prota_f <= prota_ini(NIV_GO,0);
									prota_c <= prota_ini(NIV_GO,1);
								else
									lifes <= lifes(2 downto 0) & '0';
									prota_f <= prota_ini(niv,0);
									prota_c <= prota_ini(niv,1);
									vida <= 15;
								end if;
							end if;
						elsif (color_up = 11) then
							if (vida > D_LAVA) then
								vida <= vida - D_LAVA;
								prota_f <= prota_f - 32;
								prota_c <= prota_c;
							else 
								if (lifes = "0000") then
									niv <= NIV_GO;
									new_level <= '0';
									prota_f <= prota_ini(NIV_GO,0);
									prota_c <= prota_ini(NIV_GO,1);
								else
									lifes <= lifes(2 downto 0) & '0';
									prota_f <= prota_ini(niv,0);
									prota_c <= prota_ini(niv,1);
									vida <= VIDA_FULL;
								end if;
							end if;
						elsif (color_up = 6) then
								prota_f <= prota_f - LONG_PIXI;
								prota_c <= prota_c;
								new_level <= '1';
						else
							if (vida > D_VEN) then
								vida <= vida - D_VEN;
								prota_f <= prota_f - LONG_PIXI;
								prota_c <= prota_c;
							else 
								if (lifes = "0000") then
									niv <= NIV_GO;
									new_level <= '0';
									prota_f <= prota_ini(NIV_GO,0);
									prota_c <= prota_ini(NIV_GO,1);
								else
									lifes <= lifes(2 downto 0) & '0';
									prota_f <= prota_ini(niv,0);
									prota_c <= prota_ini(niv,1);
									vida <= VIDA_FULL;
								end if;
							end if;
						end if;
					elsif (B_DOWN = '0' and new_mov = '0') then
						new_mov <= '1';
						if (color_dw = 1 or color_dw = 8 or color_dw = 14) then
							prota_f <= prota_f;
							prota_c <= prota_c;
						elsif (color_dw = 7) then
							prota_f <= prota_f + LONG_PIXI;
							prota_c <= prota_c;
						elsif (color_dw = 9) then
							if (vida > D_MOHO) then
								vida <= vida - D_MOHO;
								prota_f <= prota_f + LONG_PIXI;
								prota_c <= prota_c;
							else 
								if (lifes = "0000") then
									niv <= NIV_GO;
									new_level <= '0';
									prota_f <= prota_ini(NIV_GO,0);
									prota_c <= prota_ini(NIV_GO,1);
								else
									lifes <= lifes(2 downto 0) & '0';
									prota_f <= prota_ini(niv,0);
									prota_c <= prota_ini(niv,1);
									vida <= VIDA_FULL;
								end if;
							end if;
						elsif (color_dw = 2) then
							if (vida > D_FUEGO) then
								vida <= vida - D_FUEGO;
								prota_f <= prota_f + LONG_PIXI;
								prota_c <= prota_c;
							else 
								if (lifes = "0000") then
									niv <= NIV_GO;
									new_level <= '0';
									prota_f <= prota_ini(NIV_GO,0);
									prota_c <= prota_ini(NIV_GO,1);
								else
									lifes <= lifes(2 downto 0) & '0';
									prota_f <= prota_ini(niv,0);
									prota_c <= prota_ini(niv,1);
									vida <= VIDA_FULL;
								end if;
							end if;
						elsif (color_dw = 11) then
							if (vida > D_LAVA) then
								vida <= vida - D_LAVA;
								prota_f <= prota_f + LONG_PIXI;
								prota_c <= prota_c;
							else 
								if (lifes = "0000") then
									niv <= NIV_GO;
									new_level <= '0';
									prota_f <= prota_ini(NIV_GO,0);
									prota_c <= prota_ini(NIV_GO,1);
								else
									lifes <= lifes(2 downto 0) & '0';
									prota_f <= prota_ini(niv,0);
									prota_c <= prota_ini(niv,1);
									vida <= VIDA_FULL;
								end if;
							end if;
						elsif (color_dw = 6) then
								prota_f <= prota_f + LONG_PIXI;
								prota_c <= prota_c;
								new_level <= '1';
						else
							if (vida > D_VEN) then
								vida <= vida - D_VEN;
								prota_f <= prota_f + LONG_PIXI;
								prota_c <= prota_c;
							else 
								if (lifes = "0000") then
									niv <= NIV_GO;
									new_level <= '0';
									prota_f <= prota_ini(NIV_GO,0);
									prota_c <= prota_ini(NIV_GO,1);
								else
									lifes <= lifes(2 downto 0) & '0';
									prota_f <= prota_ini(niv,0);
									prota_c <= prota_ini(niv,1);
									vida <= VIDA_FULL;
								end if;
							end if;
						end if;			
					elsif (B_LEFT = '0' and new_mov = '0') then
						new_mov <= '1';
						if (color_lf = 1 or color_lf = 8 or color_lf = 14) then
							prota_f <= prota_f;
							prota_c <= prota_c;
						elsif (color_lf = 7) then
							prota_f <= prota_f;
							prota_c <= prota_c - LONG_PIXI;
						elsif (color_lf = 9) then
							if (vida > D_MOHO) then
								vida <= vida - D_MOHO;
								prota_f <= prota_f;
								prota_c <= prota_c - LONG_PIXI;
							else 
								if (lifes = "0000") then
									niv <= NIV_GO;
									new_level <= '0';
									prota_f <= prota_ini(NIV_GO,0);
									prota_c <= prota_ini(NIV_GO,1);
								else
									lifes <= lifes(2 downto 0) & '0';
									prota_f <= prota_ini(niv,0);
									prota_c <= prota_ini(niv,1);
									vida <= VIDA_FULL;
								end if;
							end if;
						elsif (color_lf = 2) then
							if (vida > D_FUEGO) then
								vida <= vida - D_FUEGO;
								prota_f <= prota_f;
								prota_c <= prota_c - LONG_PIXI;
							else 
								if (lifes = "0000") then
									niv <= NIV_GO;
									new_level <= '0';
									prota_f <= prota_ini(NIV_GO,0);
									prota_c <= prota_ini(NIV_GO,1);
								else
									lifes <= lifes(2 downto 0) & '0';
									prota_f <= prota_ini(niv,0);
									prota_c <= prota_ini(niv,1);
									vida <= VIDA_FULL;
								end if;
							end if;
						elsif (color_lf = 11) then
							if (vida > D_LAVA) then
								vida <= vida - D_LAVA;
								prota_f <= prota_f;
								prota_c <= prota_c - LONG_PIXI;
							else 
								if (lifes = "0000") then
									niv <= NIV_GO;
									new_level <= '0';
									prota_f <= prota_ini(NIV_GO,0);
									prota_c <= prota_ini(NIV_GO,1);
								else
									lifes <= lifes(2 downto 0) & '0';
									prota_f <= prota_ini(niv,0);
									prota_c <= prota_ini(niv,1);
									vida <= VIDA_FULL;
								end if;
							end if;
						elsif (color_lf = 6) then
								prota_f <= prota_f;
								prota_c <= prota_c - LONG_PIXI;
								new_level <= '1';
						else
							if (vida > D_VEN) then
								vida <= vida - D_VEN;
								prota_f <= prota_f;
								prota_c <= prota_c - LONG_PIXI;
							else 
								if (lifes = "0000") then
									niv <= NIV_GO;
									new_level <= '0';
									prota_f <= prota_ini(NIV_GO,0);
									prota_c <= prota_ini(NIV_GO,1);
								else
									lifes <= lifes(2 downto 0) & '0';
									prota_f <= prota_ini(niv,0);
									prota_c <= prota_ini(niv,1);
									vida <= VIDA_FULL;
								end if;
							end if;
						end if;	
					elsif (B_RIGHT = '0' and new_mov = '0') then
						new_mov <= '1';
						if (color_rg = 1 or color_rg = 8 or color_rg = 14) then
							prota_f <= prota_f;
							prota_c <= prota_c;
						elsif (color_rg = 7) then
							prota_f <= prota_f;
							prota_c <= prota_c + LONG_PIXI;
						elsif (color_rg = 9) then
							if (vida > D_MOHO) then
								vida <= vida - D_MOHO;
								prota_f <= prota_f;
								prota_c <= prota_c + LONG_PIXI;
							else 
								if (lifes = "0000") then
									niv <= NIV_GO;
									new_level <= '0';
									prota_f <= prota_ini(NIV_GO,0);
									prota_c <= prota_ini(NIV_GO,1);
								else
									lifes <= lifes(2 downto 0) & '0';
									prota_f <= prota_ini(niv,0);
									prota_c <= prota_ini(niv,1);
									vida <= VIDA_FULL;
								end if;
							end if;
						elsif (color_rg = 2) then
							if (vida > D_FUEGO) then
								vida <= vida - D_FUEGO;
								prota_f <= prota_f;
								prota_c <= prota_c + LONG_PIXI;
							else 
								if (lifes = "0000") then
									niv <= NIV_GO;
									new_level <= '0';
									prota_f <= prota_ini(NIV_GO,0);
									prota_c <= prota_ini(NIV_GO,1);
								else
									lifes <= lifes(2 downto 0) & '0';
									prota_f <= prota_ini(niv,0);
									prota_c <= prota_ini(niv,1);
									vida <= VIDA_FULL;
								end if;
							end if;
						elsif (color_rg = 11) then
							if (vida > D_LAVA) then
								vida <= vida - D_LAVA;
								prota_f <= prota_f;
								prota_c <= prota_c + LONG_PIXI;
							else 
								if (lifes = "0000") then
									niv <= NIV_GO;
									new_level <= '0';
									prota_f <= prota_ini(NIV_GO,0);
									prota_c <= prota_ini(NIV_GO,1);
								else
									lifes <= lifes(2 downto 0) & '0';
									prota_f <= prota_ini(niv,0);
									prota_c <= prota_ini(niv,1);
									vida <= VIDA_FULL;
								end if;
							end if;
						elsif (color_rg = 6) then
								prota_f <= prota_f;
								prota_c <= prota_c + LONG_PIXI;
								new_level <= '1';
						else
							if (vida > D_VEN) then
								vida <= vida - D_VEN;
								prota_f <= prota_f;
								prota_c <= prota_c + LONG_PIXI;
							else 
								if (lifes = "0000") then
									niv <= NIV_GO;
									new_level <= '0';
									prota_f <= prota_ini(NIV_GO,0);
									prota_c <= prota_ini(NIV_GO,1);
								else
									lifes <= lifes(2 downto 0) & '0';
									prota_f <= prota_ini(niv,0);
									prota_c <= prota_ini(niv,1);
									vida <= VIDA_FULL;
								end if;
							end if;
						end if;
					else
					
						--Si no se pulsa ningun boton de moviemiento o aun no se sulete no cambia de posicion al
						--protagonista, en el momento en que sueltan todos los botones se asigna la señal de moviento
						--en 0 para que se pueda realizar otro moviento
					
						prota_f <= prota_f;
						prota_c <= prota_c;
						if(B_UP = '0' or B_DOWN = '0' or B_LEFT = '0' or B_RIGHT = '0') then
							new_mov <= '1';
						else
							new_mov <= '0';
						end if;
					end if;
					
				--Si se encuentra en alguna pantalla no jugable y no es necesario cambiar de nivel espera
				--a que se presione algun boton de movimiento para activar la señal se nuevo nivel, 
				--para esto previamente se devio haber soltado
				--el boton que condujo a la pantalla actual, esto se hizo para que cuando se cambien las pantallas
				--y no se suelte el boton no cambiara inmediatamente
				
				elsif ((niv = NIV_INI or niv = NIV_WIN or niv = NIV_GO) and new_level = '0') then
					if (B_UP = '0' or B_DOWN = '0' or B_LEFT = '0' or B_RIGHT = '0') then
						if (new_mov = '0') then
							new_mov <= '1';
							new_level <= '1';
						else
							new_level <= '0';
							new_mov <= '1';
						end if;
					else
						new_mov <= '0';
						new_level <= '0';
					end if;
					
				--Si se esta apunto de inicial el primer nivel se le asigna la vida al jugador y todas las lifes, asi como
				--asignar la posicion inicial del protagonista
				elsif (niv = NIV_INI and new_level = '1') then
					niv <= 1;
					new_level <= '0';
					lifes <= "1111";
					prota_f <= prota_ini(1,0);
					prota_c <= prota_ini(1,1);
					vida <= VIDA_FULL;
				
				--Si se completa un nivel y no es el ultimo se incrementa el nivel, se le asigna la posicion al protagonista
				--y la vida completa al protagonista
				elsif (niv > NIV_INI and niv < NUM_NIV and new_level = '1') then
					niv <= niv + 1;
					new_level <= '0';
					prota_f <= prota_ini(niv + 1,0);
					prota_c <= prota_ini(niv + 1,1);
					vida <= VIDA_FULL;
					
				--Si se completo el ultimo nivel se asigna el nivel de victoria
				elsif (niv = NUM_NIV and new_level = '1') then
					niv <= NIV_WIN;
					new_level <= '0';
					prota_f <= prota_ini(NIV_WIN,0);
					prota_c <= prota_ini(NIV_WIN,1);
					
				--El ultimo caso es cuando en la pantalla de game over o de victoria hay una señal de nuevo nivel,
				--en este caso asigna el nivel en el inicial o la pantalla de inicio.
				else
					niv <= NIV_INI;
					new_level <= '0';
					prota_f <= prota_ini(NIV_INI,0);
					prota_c <= prota_ini(NIV_INI,1);
				end if;
			end if;
		end if;
	end process;

	LEDS <= lifes;

end Behavioral;

