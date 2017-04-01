LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY VGA_CONTROLLER IS
PORT( 	CLOCK_50:IN STD_LOGIC;
			SW : IN STD_LOGIC_VECTOR(0 TO 17);
			RGB 	: IN STD_LOGIC_VECTOR(29 DOWNTO 0);
			--R,G,B	: OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
			REQ     : OUT STD_LOGIC;
			--ACK     : IN STD_LOGIC;
			VGA_CLK,VGA_SYNC,VGA_BLANK,VGA_VS,
			VGA_HS	: OUT STD_LOGIC;

			VGA_R :OUT STD_LOGIC_VECTOR(0 TO 9);
			VGA_G :OUT STD_LOGIC_VECTOR(0 TO 9);
			VGA_B :OUT STD_LOGIC_VECTOR(0 TO 9);
			X       : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
			Y       : OUT STD_LOGIC_VECTOR(8 DOWNTO 0)
	);
END VGA_CONTROLLER ;

ARCHITECTURE STRUCTURE OF VGA_CONTROLLER IS


COMPONENT FIFO_CTRL IS
PORT( 	CLOCK,RESETN:IN STD_LOGIC;
		DATA_IN : IN STD_LOGIC_VECTOR(29 DOWNTO 0);
		DATA_OUT: OUT STD_LOGIC_VECTOR(29 DOWNTO 0);
		REQ     : OUT STD_LOGIC;
		POP     : IN STD_LOGIC;
		X       : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
	   Y       : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
		ACK     : IN STD_LOGIC;
		EMPTY   : OUT STD_LOGIC 
	);                                
END COMPONENT;

COMPONENT VGASINCR is
port( 
	   CLK,RESETN,EMPTY: IN STD_LOGIC;
	   VGA_CLOCK,VGA_SINK,VGA_BLANK,VGA_VS,VGA_HS,POP : OUT STD_LOGIC );                                
END COMPONENT;


SIGNAL POP_S,EMPTY_S: STD_LOGIC;
SIGNAL DATI_USCITA: STD_LOGIC_VECTOR(29 DOWNTO 0);
SIGNAL RESETN,CLOCK: STD_LOGIC;
signal ingressi_sw:std_logic_vector(29 DOWNTO 0);

BEGIN
RESETN<=SW(0);
ckdiv: process (CLOCK_50, SW(0))                  -- Divisore di frequenza. Freq in uscita pari a 25MHz
begin  
if SW(0) = '0' then                               -- Asynchronous reset (active low)
	CLOCK <= '0';
    elsif CLOCK_50'event and CLOCK_50 = '1' then  -- Rising clock edge
		CLOCK <= not CLOCK;
    end if;
end process ckdiv;
 
V_S: VGASINCR  port map ( RESETN=>RESETN,CLK=>CLOCK,POP=>POP_S,EMPTY=>EMPTY_S,
									VGA_BLANK=>VGA_BLANK,VGA_VS=>VGA_VS,VGA_HS=>VGA_HS,VGA_SINK=>VGA_SYNC,VGA_CLOCK=>VGA_CLK);
F_C: FIFO_CTRL port map ( RESETN=>RESETN,CLOCK=>CLOCK,X=>X,Y=>Y,DATA_IN=>ingressi_sw,--sostituire ingressi_sw con rgb
						  REQ=>REQ,ACK=>sw(1),POP=>POP_S,EMPTY=>EMPTY_S,--sostituire sw(1) con ack per test
						  DATA_OUT=>DATI_USCITA); 

ingressi_sw(15 downto 0)<=sw(2 to 17);
ingressi_sw(29 downto 16)<=(others=>'0');				 
						 
VGA_R(8 TO 9)<=DATI_USCITA(1 DOWNTO 0);
VGA_B(7 TO 9)<=DATI_USCITA(4 DOWNTO 2);
VGA_G(7 TO 9)<=DATI_USCITA(7 DOWNTO 5);

--VGA_R(8)<=DATI_USCITA(7);
--VGA_R(9)<=DATI_USCITA(7); 
--VGA_G<=(OTHERS=>'1');
--
--
--
--
VGA_R(7)<='0';
VGA_R(6)<='0';
VGA_R(5)<='0';
VGA_R(4)<='0';
VGA_R(3)<='0';
VGA_R(2)<='0';
VGA_R(1)<='0';
VGA_R(0)<='0';
-------

VGA_G(6)<='0';
VGA_G(5)<='0';
VGA_G(4)<='0';
VGA_G(3)<='0';
VGA_G(2)<='0';
VGA_G(1)<='0';
VGA_G(0)<='0';
-------
VGA_B(6)<='0';
VGA_B(5)<='0';
VGA_B(4)<='0';
VGA_B(3)<='0';
VGA_B(2)<='0';
VGA_B(1)<='0';
VGA_B(0)<='0';

--VGA_G(0)<=DATI_USCITA(7);
--VGA_G(1)<=DATI_USCITA(7);
--VGA_G(2)<=DATI_USCITA(7);
--VGA_G(3)<=DATI_USCITA(7);
--VGA_G(4)<=DATI_USCITA(7);
--VGA_G(5)<=DATI_USCITA(7);    
--VGA_G(6)<=DATI_USCITA(7);    
--VGA_G(7)<=DATI_USCITA(7);
--VGA_G(8)<=DATI_USCITA(7);
--VGA_G(9)<=DATI_USCITA(7);
--VGA_B(0)<=DATI_USCITA(7);
--VGA_B(1)<=DATI_USCITA(7);
--VGA_B(2)<=DATI_USCITA(7);
--VGA_B(3)<=DATI_USCITA(7);
--VGA_B(4)<=DATI_USCITA(7);
--VGA_B(5)<=DATI_USCITA(7);    
--VGA_B(6)<=DATI_USCITA(7);    
--VGA_B(7)<=DATI_USCITA(7);
--VGA_B(8)<=DATI_USCITA(7);
--VGA_B(9)<=DATI_USCITA(7);


END STRUCTURE;
