LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


ENTITY TRASMETTITORE IS
PORT( TX_DATA_IN : IN  STD_LOGIC_VECTOR(0 to 7); -- 8 BIT DI INGRESSO
      TX_DATA_OUT: OUT STD_LOGIC;      --BIT DI USCITA
      CLOCK: IN STD_LOGIC;      --CLOCK DI SISTEMA
      TX_REQ: IN STD_LOGIC;     --RICHIESTA DI TRASMISSIONE DATO
      TX_DONE: OUT STD_LOGIC;     --TX AVVENUTA
      RESETN : IN STD_LOGIC);   -- RESET ASINCRONO ATTIVO BASSO
END TRASMETTITORE;

ARCHITECTURE BEHAV OF TRASMETTITORE IS 

COMPONENT Nbit_SHIFTER_PS IS
GENERIC (N: POSITIVE := 8);
PORT (Data_Input: IN STD_LOGIC_VECTOR(0 to N-1); --Dato Parallelo in Ingresso 
	  SE: IN STD_LOGIC;                          --Shift Enable
	  LE: IN STD_LOGIC;                          --Load Enable: se attivo carica nella shifter Data_input
	  A_RST_n: IN STD_LOGIC;                     --Reset Asincrono Attivo Basso
	  CLK: IN STD_LOGIC;                         --Clock di sistema
	  Data_Output: OUT STD_LOGIC);               --Dato Serial in uscita
END COMPONENT;

COMPONENT Contatore_Modulo_N IS
GENERIC (N: POSITIVE := 10;
		 M: POSITIVE := 4);
PORT (Data_Input: IN STD_LOGIC_VECTOR(M-1 downto 0);   --Dato caricabile in ingresso da cui cominciare a contare
	  LD: IN STD_LOGIC;                                    --Load: se asserito carica nel contatore Data_Input
	  CE: IN STD_LOGIC;                                    --Counter Enable: se asserito abilita il contatore a contare
	  A_RST_n: IN STD_LOGIC;                               --Reset asincrono attivo basso
	  CLK: IN STD_LOGIC;                                   --Clock di sistema
	  Data_Output: BUFFER STD_LOGIC_VECTOR(M-1 downto 0); 
	  TC: OUT STD_LOGIC);                                  --Terminal Count: viene asserito quando Data_Output = N-1
END COMPONENT;

TYPE STATE_TYPE IS ( IDLE , T_REQ ,LOAD ,SHIFT_IN ,SHIFT_END, STATE_DONE);
SIGNAL STATE :STATE_TYPE;
SIGNAL SE,LE : STD_LOGIC;
SIGNAL LD,CE,TC : STD_LOGIC;-- SEGNALI PER IL CONTATORE MODULO 2605
SIGNAL DATA_OUT_COUNTER :STD_LOGIC_VECTOR(11 DOWNTO 0);  --NUMERO IN USCITA DAL CONTATORE 2605
SIGNAL DATA_IN_COUNTER :STD_LOGIC_VECTOR(11 DOWNTO 0) := "000000000000"; -- NUMERO CHE PUOI CARICARE NEL CONTATORE
SIGNAL LD11,CE11,TC11 : STD_LOGIC;-- SEGNALI PER IL CONTATORE MODULO 11
SIGNAL DATA_IN_COUNTER11 :STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000"; --NUMERO CHE PUOI CARICARE NEL CONTATORE
SIGNAL DATA_OUT_COUNTER11 :STD_LOGIC_VECTOR(3 DOWNTO 0);  --NUMERO IN USCITA DAL CONTATORE 11


BEGIN 
TRANSITION: PROCESS( RESETN, CLOCK)
BEGIN
IF RESETN='0' THEN  STATE<= IDLE;
ELSIF ( CLOCK' EVENT AND CLOCK='1') THEN 
CASE STATE IS 
     WHEN IDLE => IF TX_REQ='0' THEN STATE<= IDLE; ELSE STATE<= T_REQ;END IF;
     WHEN T_REQ => STATE<=LOAD;
     WHEN LOAD => IF TC='1' THEN STATE<= SHIFT_IN; ELSE STATE<=LOAD;END IF;
     WHEN SHIFT_IN =>  STATE<= SHIFT_END;
     WHEN SHIFT_END => IF TC11='1' THEN STATE<=STATE_DONE; ELSE STATE<= LOAD;END IF;
     WHEN STATE_DONE => IF TX_REQ = '0' THEN STATE <= STATE_DONE; ELSE STATE <= T_REQ; END IF;
     END CASE;
    END IF;
 END PROCESS;

 ASM_OUTPUTS: PROCESS( STATE)
BEGIN
SE<='0';
LE<='0';
LD<='0';
CE<='0';
LD11<='0';
CE11<='0';
TX_DONE<='0';
CASE STATE IS
WHEN IDLE=>
WHEN T_REQ =>
     CE<='1';
     LE<='1';
WHEN LOAD =>
	 CE <= '1';
WHEN SHIFT_IN => 
     CE11<='1';
     SE<='1';  
WHEN SHIFT_END => 
     CE11<='0';
     SE<='0'; 
WHEN STATE_DONE =>
    CE<='0';
    CE11<='0';
   TX_DONE<='1';
     END CASE;
 END PROCESS;
 
 
 COUNT2065 :Contatore_Modulo_N  GENERIC MAP (N=> 2065,M=> 12)
       PORT MAP(Data_Input=>DATA_IN_COUNTER,LD=>LD,CE=>CE,A_RST_n=>RESETN,CLK=>CLOCK,Data_Output=>DATA_OUT_COUNTER,TC=>TC);
 COUNT11 :Contatore_Modulo_N  GENERIC MAP (N=>11,M=> 4)
       PORT MAP(Data_Input=>DATA_IN_COUNTER11,LD=>LD11,CE=>CE11,A_RST_n=>RESETN,CLK=>CLOCK,Data_Output=>DATA_OUT_COUNTER11,TC=>TC11);
       
SHIFTER_TX: Nbit_SHIFTER_PS GENERIC MAP (N=>10)
       PORT MAP(Data_Input(0)=>'1',Data_Input(1 TO 8)=>TX_DATA_IN,Data_Input(9)=>'0',SE=>SE,LE=>LE,A_RST_n=>RESETN,CLK=>CLOCK,Data_Output=>TX_DATA_OUT);
END BEHAV;