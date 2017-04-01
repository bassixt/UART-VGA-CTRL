LIBRARY IEEE;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Cont524 IS
PORT (                                   
	  CE2: IN STD_LOGIC;                                  
	  RESETN: IN STD_LOGIC;                             
	  CLK: IN STD_LOGIC;                                   
	  OUTCON2: OUT UNSIGNED(9 downto 0); 
	  TCL1: OUT STD_LOGIC;
	  TCL34: OUT STD_LOGIC;
	  TCL514: OUT STD_LOGIC;
	  TCL524: OUT STD_LOGIC);                                  
END Cont524;

ARCHITECTURE BEHAV OF Cont524 IS


 BEGIN
Counter: PROCESS(CLK, RESETN)
 variable TMP_Counter: UNSIGNED(9 DOWNTO 0);
BEGIN

IF RESETN = '0' THEN
	TMP_Counter := (others => '0');
	TCL1 <= '0';
	TCL34 <= '0';
	TCL514<= '0';
	TCL524<= '0';
ELSIF CLK'EVENT AND CLK = '1' THEN
	--TCL1 <= '0';
	--TCL34 <= '0';
	--TCL514<= '0';
	--TCL524<= '0';     
 IF CE2 = '1' THEN
   IF TMP_Counter=524 THEN
     TMP_Counter:="0000000000";
   --  TCL524<='1';
    ELSE
   TMP_Counter:=TMP_Counter+1;
end if;
     CASE to_integer(TMP_counter) IS 
     WHEN 1 => TCL1<='1';
     WHEN 34 => TCL34<='1'; 
     WHEN 514 => TCL514<='1'; 
    WHEN 524=> TCL524<='1';
   WHEN OTHERS=>
   	TCL1 <= '0';
	TCL34 <= '0';
	TCL514<= '0';
	TCL524<= '0';
     END CASE;
  --   TMP_Counter:=TMP_Counter+1;
--END IF;
END IF;
END IF;
OUTCON2<=TMP_Counter;
END PROCESS;

END BEHAV;