-- N bit shifter Seriale Parallelo
-- 0 = MSB, N-1 = LSB
-- Lo shift va dal MSB al LSB
-- Il dato seriale in ingresso deve essere inviato LSB first

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Nbit_SHIFTER_SP IS
GENERIC (N: POSITIVE := 8);
PORT (Data_Input: IN STD_LOGIC;                               --Dato in ingresso
	  SE:  IN STD_LOGIC;                                      --Shift Enable 
	  A_RST_n:  IN STD_LOGIC;                                 --Reset Asincrono attivo basso
	  CLK:  IN STD_LOGIC;                                     --Clock di Sistema
	  Data_Output:  BUFFER STD_LOGIC_VECTOR(0 to N-1));   --Dato in output
END Nbit_SHIFTER_SP;

ARCHITECTURE behovior OF Nbit_SHIFTER_SP IS

BEGIN

SHIFTER: PROCESS(CLK, A_RST_n)
BEGIN
IF A_RST_n = '0' THEN
	Data_Output <= (others => '0');
ELSIF CLK = '1' AND CLK'EVENT THEN
	IF SE = '1' THEN
		Data_Output <= Data_Input & Data_Output(0 to N-2);      --Shifta di una posizione a destra
	END IF;
END IF;
END PROCESS;

END ARCHITECTURE; 
 