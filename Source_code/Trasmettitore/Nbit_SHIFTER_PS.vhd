-- Nbit_SHIFTER_PS
-- Shifter Parallelo-Seriale ad N bit
-- 0 = MSB, N-1 = LSB
-- In uscita viene portato il LSB
-- I dati caricati nello shifter vengono da shiftati dal MSB verso il LSB; MSB sostituito da 0
-- Se LE e SE asseriti contemporaneamente, LE è ignorato

LIBRARY IEEE;
USE ieee.std_logic_1164.all;

ENTITY Nbit_SHIFTER_PS IS
GENERIC (N: POSITIVE := 8);
PORT (Data_Input: IN STD_LOGIC_VECTOR(0 to N-1); --Dato Parallelo in Ingresso 
	  SE: IN STD_LOGIC;                          --Shift Enable
	  LE: IN STD_LOGIC;                          --Load Enable: se attivo carica nella shifter Data_input
	  A_RST_n: IN STD_LOGIC;                     --Reset Asincrono Attivo Basso
	  CLK: IN STD_LOGIC;                         --Clock di sistema
	  Data_Output: OUT STD_LOGIC);               --Dato Serial in uscita
END Nbit_SHIFTER_PS;

ARCHITECTURE behavior of Nbit_SHIFTER_PS IS

SIGNAL Data_Charged: STD_LOGIC_VECTOR(0 to N-1); --Dati caricati nello shifter
SIGNAL Fill_Bit: STD_LOGIC := '0';               --Utilizzato per sostituire l'MSB con uno 0

BEGIN

SHIFTER_PS: PROCESS (CLK, A_RST_n)
BEGIN
IF A_RST_n = '0' THEN
	Data_Output <= '0';
	Data_Charged <= (others => '0');
ELSIF CLK'EVENT AND CLK = '1' THEN
	IF LE = '1' THEN
		Data_Charged <= Data_Input;
	END IF;
	IF SE = '1' THEN
		Data_Output <= Data_Charged(N-1);
		Data_Charged <= Fill_Bit & Data_Charged(0 to N-2);
	END IF;
END IF;
END PROCESS;

END behavior;