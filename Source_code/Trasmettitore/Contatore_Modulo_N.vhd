-- Contatore Modulo N
-- Se LD e CE asseriti contemporaneamente, prevale LD

LIBRARY IEEE;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY Contatore_Modulo_N IS
GENERIC (N: POSITIVE := 10;
		 M: POSITIVE := 4);
PORT (Data_Input: IN STD_LOGIC_VECTOR(M-1 downto 0);   --Dato caricabile in ingresso da cui cominciare a contare
	  LD: IN STD_LOGIC;                                    --Load: se asserito carica nel contatore Data_Input
	  CE: IN STD_LOGIC;                                    --Counter Enable: se asserito abilita il contatore a contare
	  A_RST_n: IN STD_LOGIC;                               --Reset asincrono attivo basso
	  CLK: IN STD_LOGIC;                                   --Clock di sistema
	  Data_Output: BUFFER STD_LOGIC_VECTOR(M-1 downto 0); 
	  TC: OUT STD_LOGIC);                                  --Terminal Count: viene asserito quando Data_Output = N-1
END Contatore_Modulo_N;

ARCHITECTURE behavior OF Contatore_Modulo_N IS

SIGNAL TMP_Counter: UNSIGNED(M-1 DOWNTO 0);  --Contatore ausiliare

BEGIN

Counter: PROCESS(CLK, A_RST_n)
BEGIN
IF A_RST_n = '0' THEN
	TMP_Counter <= (others => '0');
	TC <= '0';
ELSIF CLK'EVENT AND CLK = '1' THEN
	TC <= '0';
	IF LD = '1' THEN
		TMP_Counter <= UNSIGNED(Data_Input);
	ELSIF CE = '1' THEN
		IF TMP_Counter = N-1 THEN
			TMP_Counter <= (others => '0');
		ELSE 
			TMP_Counter <= TMP_Counter + 1;
		END IF;
		IF TMP_Counter = N-2 THEN  --Faccio il controllo su N-2, perchè TMP_Counter è di tipo signal e non variable
			TC <= '1';
		END IF;
	END IF;
END IF;
Data_Output <= STD_LOGIC_VECTOR(TMP_Counter);
END PROCESS;

END behavior;
			