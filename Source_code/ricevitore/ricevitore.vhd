LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


ENTITY RICEVITORE IS
PORT( TX_DATA_IN : IN  STD_LOGIc; -- BIT DI INGRESSO
      TX_DATA_OUT: OUT STD_LOGIC_VECTOR(0 TO 7);      -- 8BIT DI USCITA
      CLOCK: IN STD_LOGIC;      --CLOCK DI SISTEMA
      DATA_READY: OUT STD_LOGIC;     -- DATO PRONTO
      ERROR: OUT STD_LOGIC;     --ERRORE
      RESETN : IN STD_LOGIC);   -- RESET ASINCRONO ATTIVO BASSO
END RICEVITORE;

ARCHITECTURE BEHAV OF RICEVITORE IS
	  
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

COMPONENT Nbit_SHIFTER_SP IS
GENERIC (N: POSITIVE := 8);
PORT (Data_Input: IN STD_LOGIC;                               --Dato in ingresso
	  SE:  IN STD_LOGIC;                                      --Shift Enable 
	  A_RST_n:  IN STD_LOGIC;                                 --Reset Asincrono attivo basso
	  CLK:  IN STD_LOGIC;                                     --Clock di Sistema
	  Data_Output:  BUFFER STD_LOGIC_VECTOR(0 to N-1));   --Dato in output
END COMPONENT;
COMPONENT voter IS
PORT ( c1,c2,c3,c4,c5 : IN STD_LOGIC ;
       v : OUT STD_LOGIC ) ;
END COMPONENT ;

TYPE STATE_TYPE IS ( IDLE,SHIFT_EN ,SHIFT_NOTEN, STARTBIT_STATE,STOPCOUNT2,COUNTEN2,NOT_COUNT_EN2,COUNT_EN3,NOT_COUNT_EN3,NOTHING,ER_SHIFT_EN,ER_SHIFT_NOTEN,
                          CONTR_ERR,DATA_ERR,DATA_READY_STATE,SE_DATA_ERROR,SE_DATA_READY,NSE_DATA_ERROR,NSE_DATA_READY);--,SHIFT_EN2,SHIFT_NOTEN2
SIGNAL STATE :STATE_TYPE;
SIGNAL TC1,TC2,TC3,CE1,CE2,CE3,LD1,LD2,LD3: STD_LOGIC;
SIGNAL DATAINCOUNT1: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL DATAOUTCOUNT1: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL DATAINCOUNT2: STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL DATAOUTCOUNT2: STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL DATAINCOUNT3: STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL DATAOUTCOUNT3: STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL DATAVOTER: STD_LOGIC;
SIGNAL SE1,SE2  : STD_LOGIC;
SIGNAL DATAOUTREG1: STD_LOGIC_VECTOR(0 TO 15);
SIGNAL CONTR_ERR0R: STD_LOGIC;
SIGNAL STARTBIT: STD_LOGIC;
SIGNAL ERR: STD_LOGIC;


BEGIN 
TRANSITION: PROCESS( RESETN, CLOCK)
BEGIN
IF RESETN='0' THEN  STATE<= IDLE;
ELSIF ( CLOCK' EVENT AND CLOCK='1') THEN 
CASE STATE IS 
     WHEN IDLE => IF TC1='1' THEN STATE<=SHIFT_EN ; ELSE STATE<= IDLE;END IF;
     WHEN SHIFT_EN => STATE<=SHIFT_NOTEN;
     WHEN SHIFT_NOTEN => IF STARTBIT='1' THEN STATE<= STARTBIT_STATE; ELSE STATE<=IDLE;END IF;
     WHEN STARTBIT_STATE=> STATE<= STOPCOUNT2;
     WHEN STOPCOUNT2=> IF TC1='1' THEN STATE<=COUNTEN2 ; ELSE STATE<= STOPCOUNT2;END IF;
     WHEN COUNTEN2=>STATE<=NOT_COUNT_EN2;
     WHEN NOT_COUNT_EN2=> IF TC2='1' THEN STATE<=COUNT_EN3 ; ELSE STATE<= STOPCOUNT2;END IF;
     WHEN COUNT_EN3=> STATE<=NOT_COUNT_EN3;
     WHEN NOT_COUNT_EN3=> IF TC3='1' THEN STATE<=NOTHING; ELSE STATE<=STOPCOUNT2;END IF;
    -- WHEN SHIFT_EN2=> STATE<=SHIFT_NOTEN2;
    -- WHEN SHIFT_NOTEN2=> STATE<=NOTHING;
     WHEN NOTHING=> IF TC1='1' THEN STATE<=ER_SHIFT_EN; ELSE STATE<= NOTHING;END IF;
     WHEN ER_SHIFT_EN=> STATE<=ER_SHIFT_NOTEN;
     WHEN ER_SHIFT_NOTEN =>IF  TC2='1' THEN STATE<=CONTR_ERR ; ELSE STATE<=NOTHING;END IF;
     WHEN CONTR_ERR=> IF ERR='1' THEN STATE<=DATA_ERR ; ELSE STATE<= DATA_READY_STATE;END IF;
     WHEN  DATA_ERR=> IF TC1='1' THEN STATE<=SE_DATA_ERROR; ELSE STATE<= DATA_ERR;END IF;
     WHEN  DATA_READY_STATE=> IF TC1='1' THEN STATE<=SE_DATA_READY; ELSE STATE<= DATA_READY_STATE;END IF;
     WHEN  SE_DATA_ERROR=> STATE<=NSE_DATA_ERROR;
     WHEN  SE_DATA_READY=> STATE<=NSE_DATA_READY;
     WHEN  NSE_DATA_ERROR=> IF STARTBIT='1' THEN STATE<=STARTBIT_STATE; ELSE STATE<= DATA_ERR;END IF;
     WHEN  NSE_DATA_READY=> IF STARTBIT='1' THEN STATE<=STARTBIT_STATE; ELSE STATE<= DATA_READY_STATE;END IF;
     END CASE;
    END IF;
 END PROCESS;
ASM_OUTPUTS: PROCESS( STATE)
BEGIN
CE1<='1';
CE3<='0';
CE2<='0';
LD1<='0';
LD2<='0';
LD3<='0';
SE1<='0';
SE2<='0';
CONTR_ERR0R<='0';
DATA_READY<='0';
ERROR<='0';

CASE STATE IS
WHEN IDLE=>
WHEN SHIFT_EN =>
     SE1<='1';
WHEN SHIFT_NOTEN=>
     SE1<='0';
WHEN STARTBIT_STATE =>
     LD2<='1'; 
WHEN STOPCOUNT2 => 
WHEN COUNTEN2 =>
     CE2<='1';
     SE1<='1';
WHEN NOT_COUNT_EN2 =>
WHEN COUNT_EN3=>
     CE3<='1';
     SE2<='1';
WHEN NOT_COUNT_EN3=>
--WHEN SHIFT_EN2=>
--     SE2<='1';
--WHEN SHIFT_NOTEN2=>
--   SE2<='0';
WHEN NOTHING=>
WHEN ER_SHIFT_EN=>
     CE2<='1';
     SE1<='1';
WHEN ER_SHIFT_NOTEN=>
WHEN CONTR_ERR=>
     CONTR_ERR0R<='1';
WHEN DATA_ERR=>
     ERROR<='1';
WHEN DATA_READY_STATE=>
     DATA_READY<='1';
WHEN SE_DATA_ERROR=>
     SE1<='1';
     ERROR<='1';
WHEN SE_DATA_READY=>
     SE1<='1';
     DATA_READY<='1';
WHEN NSE_DATA_ERROR=>
     ERROR<='1';
     LD3<='1';
WHEN NSE_DATA_READY=>
     DATA_READY<='1';
     LD3<='1';
     END CASE;
 END PROCESS;

 COUNT164:Contatore_Modulo_N  GENERIC MAP (N=> 164,M=> 8)
       PORT MAP(Data_Input=>DATAINCOUNT1,LD=>LD1,CE=>CE1,A_RST_n=>RESETN,CLK=>CLOCK,Data_Output=>DATAOUTCOUNT1,TC=>TC1);
 COUNT16:Contatore_Modulo_N  GENERIC MAP (N=> 16,M=> 4)
       PORT MAP(Data_Input=>"0001",LD=>LD2,CE=>CE2,A_RST_n=>RESETN,CLK=>CLOCK,Data_Output=>DATAOUTCOUNT2,TC=>TC2);
 COUNT9: Contatore_Modulo_N  GENERIC MAP (N=> 10,M=> 4)
       PORT MAP(Data_Input=>"0000",LD=>LD3,CE=>CE3,A_RST_n=>RESETN,CLK=>CLOCK,Data_Output=>DATAOUTCOUNT3,TC=>TC3);
 SHIFTER16 :Nbit_SHIFTER_SP GENERIC MAP( N=>16)
       PORT MAP (Data_Input=>TX_DATA_IN,SE=>SE1,A_RST_n=>RESETN,CLK=>CLOCK,Data_Output=>DATAOUTREG1);
 SHIFTER8 :Nbit_SHIFTER_SP GENERIC MAP( N=>8)
       PORT MAP (Data_Input=>DATAVOTER,SE=>SE2,A_RST_n=>RESETN,CLK=>CLOCK,Data_Output=>TX_DATA_OUT);
STARTBIT<= NOT DATAOUTREG1(0) AND NOT DATAOUTREG1(1) AND DATAOUTREG1(2) AND DATAOUTREG1(3);
VOTER_B: VOTER PORT MAP (c1=>DATAOUTREG1(7),c2=>DATAOUTREG1(8),c3=>DATAOUTREG1(9),c4=>DATAOUTREG1(10),c5=>DATAOUTREG1(11),v=>DATAVOTER);

ERR<=NOT DATAVOTER AND CONTR_ERR0R;
END BEHAV;

