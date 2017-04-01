LIBRARY IEEE;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Cont797 IS
PORT (                                   
	  CE1: IN STD_LOGIC;                                  
	  RESETN: IN STD_LOGIC;                             
	  CLK: IN STD_LOGIC;                                   
	  OUTCON: OUT UNSIGNED(9 downto 0); 
	  TC94: OUT STD_LOGIC;
	  TC141: OUT STD_LOGIC;
	  TC781: OUT STD_LOGIC;
	  TC796: OUT STD_LOGIC);                                  
END Cont797;

ARCHITECTURE BEHAV OF Cont797 IS

 BEGIN
Counter: PROCESS(CLK, RESETN)
 variable TMP_Counter: UNSIGNED(9 DOWNTO 0);
BEGIN

IF RESETN = '0' THEN
	TMP_Counter := (others => '0');
	TC94 <= '0';
	TC141 <= '0';
	TC781<= '0';
	TC796<= '0';
ELSIF CLK'EVENT AND CLK = '1' THEN
   -- TC94 <= '0';
	--TC142 <= '0';
	--TC782<= '0';
	--TC796<= '0';     
 IF CE1 = '1' THEN
   IF TMP_Counter= 797 THEN
     TMP_Counter:="0000000000";
    ELSE
  TMP_Counter:=TMP_Counter+1;
     CASE to_integer(TMP_counter) IS 
     WHEN 94 => TC94<='1';
     WHEN 141 => TC141<='1'; 
     WHEN 781 => TC781<='1'; 
     WHEN 796=> TC796<='1';
     WHEN OTHERS => 
         TC94 <= '0';
	TC141 <= '0';
	TC781<= '0';
	TC796<= '0'; 
     END CASE;
   --  TMP_Counter:=TMP_Counter+1;
END IF;
END IF;
END IF;
OUTCON<=TMP_Counter;
END PROCESS;

END BEHAV;